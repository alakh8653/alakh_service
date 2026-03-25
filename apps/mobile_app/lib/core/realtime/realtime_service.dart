/// WebSocket connection manager with auto-reconnect logic.
///
/// Add `web_socket_channel` to your `pubspec.yaml`:
/// ```yaml
/// dependencies:
///   web_socket_channel: ^2.4.0
/// ```
library realtime_service;

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import '../config/app_config.dart';
import '../utils/logger.dart';
import 'realtime_channel.dart';
import 'realtime_events.dart';

// TODO: import 'package:web_socket_channel/web_socket_channel.dart';

/// Connection state of the [RealtimeService].
enum RealtimeConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
  disposed,
}

/// Manages a single WebSocket connection with:
/// - Automatic exponential-backoff reconnection
/// - Named channel subscriptions
/// - Heartbeat / ping-pong keep-alive
///
/// Usage:
/// ```dart
/// final service = RealtimeService(config: sl());
/// await service.connect();
/// final channel = service.channel('shop:123');
/// await channel.subscribe();
/// ```
class RealtimeService {
  RealtimeService({
    required AppConfig config,
    this.heartbeatIntervalSeconds = 30,
    this.maxReconnectAttempts = 10,
    this.initialReconnectDelayMs = 500,
  }) : _wsUrl = config.wsBaseUrl;

  final String _wsUrl;
  final int heartbeatIntervalSeconds;
  final int maxReconnectAttempts;
  final int initialReconnectDelayMs;

  final _log = AppLogger('RealtimeService');
  final _eventController = StreamController<RealtimeEvent>.broadcast();
  final _stateController =
      StreamController<RealtimeConnectionState>.broadcast();
  final Map<String, RealtimeChannel> _channels = {};

  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  bool _intentionalClose = false;

  RealtimeConnectionState _state = RealtimeConnectionState.disconnected;

  // TODO: Replace with WebSocketChannel when package is available:
  // WebSocketChannel? _channel;

  /// Current connection state.
  RealtimeConnectionState get state => _state;

  /// Stream of all incoming [RealtimeEvent]s from all channels.
  Stream<RealtimeEvent> get events => _eventController.stream;

  /// Stream of connection state changes.
  Stream<RealtimeConnectionState> get onStateChange =>
      _stateController.stream;

  /// Establishes the WebSocket connection.
  Future<void> connect() async {
    if (_state == RealtimeConnectionState.connected) return;
    _intentionalClose = false;
    _updateState(RealtimeConnectionState.connecting);

    try {
      // TODO: Replace with real WebSocket connection:
      // _channel = WebSocketChannel.connect(Uri.parse(_wsUrl));
      // _channel!.stream.listen(
      //   _handleRawMessage,
      //   onError: _handleError,
      //   onDone: _handleDisconnect,
      // );

      _reconnectAttempts = 0;
      _updateState(RealtimeConnectionState.connected);
      _startHeartbeat();
      _log.i('Connected to $_wsUrl');
    } catch (e) {
      _log.e('Connection failed: $e');
      _scheduleReconnect();
    }
  }

  /// Closes the WebSocket connection cleanly.
  Future<void> disconnect() async {
    _intentionalClose = true;
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    // TODO: await _channel?.sink.close();
    _updateState(RealtimeConnectionState.disconnected);
    _log.i('Disconnected');
  }

  /// Returns or creates a [RealtimeChannel] for the given [topic].
  RealtimeChannel channel(String topic) {
    return _channels.putIfAbsent(
      topic,
      () => RealtimeChannel(
        name: topic,
        eventStream: _eventController.stream.where(
          (e) => _isForChannel(e, topic),
        ),
      ),
    );
  }

  /// Sends a raw JSON payload over the WebSocket.
  void send(Map<String, dynamic> payload) {
    if (_state != RealtimeConnectionState.connected) {
      _log.w('send() called while not connected – message dropped');
      return;
    }
    final encoded = jsonEncode(payload);
    // TODO: _channel!.sink.add(encoded);
    _log.d('Sent: $encoded');
  }

  /// Releases all resources.
  Future<void> dispose() async {
    await disconnect();
    for (final ch in _channels.values) {
      await ch.unsubscribe();
    }
    _channels.clear();
    await _eventController.close();
    await _stateController.close();
    _updateState(RealtimeConnectionState.disposed);
  }

  // ── Private ───────────────────────────────────────────────────────────────

  void _handleRawMessage(dynamic raw) {
    try {
      final json = jsonDecode(raw as String) as Map<String, dynamic>;
      final event = RealtimeEvent.fromJson(json);
      if (!_eventController.isClosed) {
        _eventController.add(event);
      }
    } catch (e) {
      _log.e('Failed to parse message: $e');
    }
  }

  void _handleError(Object error) {
    _log.e('WebSocket error: $error');
    _scheduleReconnect();
  }

  void _handleDisconnect() {
    _log.i('WebSocket disconnected');
    if (!_intentionalClose) {
      _scheduleReconnect();
    } else {
      _updateState(RealtimeConnectionState.disconnected);
    }
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(
      Duration(seconds: heartbeatIntervalSeconds),
      (_) => send({'event': 'ping', 'timestamp': DateTime.now().toIso8601String()}),
    );
  }

  void _scheduleReconnect() {
    if (_intentionalClose ||
        _reconnectAttempts >= maxReconnectAttempts ||
        _state == RealtimeConnectionState.disposed) {
      _updateState(RealtimeConnectionState.disconnected);
      return;
    }

    _reconnectAttempts++;
    _updateState(RealtimeConnectionState.reconnecting);

    // Exponential backoff capped at 30 seconds.
    final delay = math.min(
      initialReconnectDelayMs * math.pow(2, _reconnectAttempts - 1),
      30000,
    ).toInt();

    _log.i('Reconnecting in ${delay}ms (attempt $_reconnectAttempts)');

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(milliseconds: delay), connect);
  }

  void _updateState(RealtimeConnectionState newState) {
    _state = newState;
    if (!_stateController.isClosed) {
      _stateController.add(newState);
    }
  }

  /// Returns `true` if [event] belongs to [topic].
  ///
  /// Convention: event payloads carry a `channel` or `topic` field that
  /// matches the subscribed topic.
  bool _isForChannel(RealtimeEvent event, String topic) {
    // All events are broadcast to all channels – each channel filters by type.
    // For channel-specific filtering add a `topic` field to your event JSON.
    return true;
  }
}
