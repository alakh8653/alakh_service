import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'realtime_channel.dart';
import 'realtime_config.dart';
import 'realtime_connection.dart';
import 'realtime_event.dart';
import 'realtime_message.dart';
import 'backoff/exponential_backoff.dart';
import 'serialization/message_serializer.dart';

/// WebSocket client with auto-reconnect, heartbeat, and channel support.
class RealtimeClient implements RealtimeClientInterface {
  final RealtimeConfig config;
  final MessageSerializer _serializer;
  final ExponentialBackoff _backoff;

  WebSocketChannel? _wsChannel;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  StreamSubscription<dynamic>? _wsSubscription;

  final _connectionController =
      StreamController<RealtimeConnection>.broadcast();
  final _messageController = StreamController<RealtimeMessage>.broadcast();

  RealtimeConnection _connection = const RealtimeConnection(
      status: RealtimeConnectionStatus.disconnected);

  final Map<String, RealtimeChannel> _channels = {};
  int _refCounter = 0;
  bool _intentionalDisconnect = false;

  RealtimeClient({
    required this.config,
    MessageSerializer? serializer,
    ExponentialBackoff? backoff,
  })  : _serializer = serializer ?? MessageSerializer(),
        _backoff = backoff ?? ExponentialBackoff();

  Stream<RealtimeConnection> get connectionStream =>
      _connectionController.stream;
  Stream<RealtimeMessage> get messageStream => _messageController.stream;
  RealtimeConnection get connection => _connection;
  bool get isConnected => _connection.isConnected;

  Future<void> connect() async {
    if (_connection.isConnected || _connection.isConnecting) return;
    _intentionalDisconnect = false;
    _updateConnection(const RealtimeConnection(
        status: RealtimeConnectionStatus.connecting));
    try {
      _wsChannel = WebSocketChannel.connect(config.uri);
      await _wsChannel!.ready;
      _updateConnection(RealtimeConnection(
          status: RealtimeConnectionStatus.connected,
          connectedAt: DateTime.now(),
          reconnectAttempt: 0));
      _backoff.reset();
      _startHeartbeat();
      _listenToMessages();
    } catch (e) {
      _updateConnection(RealtimeConnection(
          status: RealtimeConnectionStatus.error,
          errorMessage: e.toString()));
      _scheduleReconnect();
    }
  }

  Future<void> disconnect() async {
    _intentionalDisconnect = true;
    _stopHeartbeat();
    _reconnectTimer?.cancel();
    await _wsSubscription?.cancel();
    await _wsChannel?.sink.close();
    _wsChannel = null;
    _updateConnection(RealtimeConnection(
        status: RealtimeConnectionStatus.disconnected,
        disconnectedAt: DateTime.now()));
  }

  RealtimeChannel channel(String topic) {
    return _channels.putIfAbsent(topic, () => RealtimeChannel(topic, this));
  }

  void removeChannel(String topic) {
    _channels.remove(topic)?.clearSubscriptions();
  }

  @override
  void send(RealtimeMessage message) {
    if (!isConnected) return;
    _wsChannel?.sink.add(_serializer.serialize(message));
  }

  @override
  String nextRef() => '${++_refCounter}';

  void _listenToMessages() {
    _wsSubscription = _wsChannel!.stream.listen(
      (data) {
        if (data is String) _handleMessage(data);
      },
      onError: (Object e) => _handleDisconnect(e),
      onDone: () => _handleDisconnect(null),
    );
  }

  void _handleMessage(String data) {
    final msg = _serializer.deserialize(data);
    if (msg == null) return;
    _messageController.add(msg);
    _channels[msg.topic]?.handleMessage(msg);
  }

  void _handleDisconnect(Object? error) {
    _stopHeartbeat();
    _wsChannel = null;
    if (_intentionalDisconnect) return;
    _updateConnection(RealtimeConnection(
        status: RealtimeConnectionStatus.reconnecting,
        errorMessage: error?.toString(),
        disconnectedAt: DateTime.now()));
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_intentionalDisconnect) return;
    final maxAttempts = config.maxReconnectAttempts;
    if (maxAttempts >= 0 && _backoff.attempt >= maxAttempts) {
      _updateConnection(const RealtimeConnection(
          status: RealtimeConnectionStatus.error,
          errorMessage: 'Max reconnect attempts reached'));
      return;
    }
    final delay = _backoff.nextDelay();
    _reconnectTimer = Timer(delay, connect);
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer =
        Timer.periodic(config.heartbeatInterval, (_) {
      if (isConnected) {
        send(RealtimeMessage(
            topic: RealtimeEvent.phoenixTopic,
            event: RealtimeEvent.heartbeat,
            payload: {},
            ref: nextRef()));
      }
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  void _updateConnection(RealtimeConnection conn) {
    _connection = conn;
    _connectionController.add(conn);
  }

  Future<void> dispose() async {
    await disconnect();
    for (final ch in _channels.values) ch.clearSubscriptions();
    _channels.clear();
    await _connectionController.close();
    await _messageController.close();
  }
}
