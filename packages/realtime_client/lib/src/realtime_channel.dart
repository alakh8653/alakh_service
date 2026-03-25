import 'realtime_message.dart';
import 'realtime_event.dart';
import 'realtime_subscription.dart';

/// State of a channel.
enum ChannelState { closed, joining, joined, leaving, errored }

/// Interface used by RealtimeChannel to communicate with the client.
abstract class RealtimeClientInterface {
  void send(RealtimeMessage message);
  String nextRef();
}

/// Represents a subscription to a specific topic on the WebSocket server.
class RealtimeChannel {
  final String topic;
  final RealtimeClientInterface _client;
  final Map<String, List<RealtimeSubscription>> _subscriptions = {};
  ChannelState _state = ChannelState.closed;

  RealtimeChannel(this.topic, this._client);

  ChannelState get state => _state;
  bool get isJoined => _state == ChannelState.joined;

  RealtimeSubscription on(String event, void Function(RealtimeMessage) cb) {
    final sub =
        RealtimeSubscription(topic: topic, event: event, callback: cb);
    _subscriptions.putIfAbsent(event, () => []).add(sub);
    return sub;
  }

  RealtimeSubscription onAny(void Function(RealtimeMessage) cb) =>
      on('*', cb);

  Future<void> push(String event, Map<String, dynamic> payload) async {
    _client
        .send(RealtimeMessage(topic: topic, event: event, payload: payload));
  }

  Future<void> join({Map<String, dynamic> payload = const {}}) async {
    if (_state == ChannelState.joined || _state == ChannelState.joining)
      return;
    _state = ChannelState.joining;
    _client.send(RealtimeMessage(
      topic: topic,
      event: RealtimeEvent.phxJoin,
      payload: payload,
      ref: _client.nextRef(),
      joinRef: _client.nextRef(),
    ));
    _state = ChannelState.joined;
  }

  Future<void> leave() async {
    if (_state == ChannelState.closed || _state == ChannelState.leaving)
      return;
    _state = ChannelState.leaving;
    _client.send(RealtimeMessage(
      topic: topic,
      event: RealtimeEvent.phxLeave,
      payload: {},
      ref: _client.nextRef(),
    ));
    _state = ChannelState.closed;
  }

  void handleMessage(RealtimeMessage message) {
    final eventSubs = _subscriptions[message.event] ?? [];
    final wildSubs = _subscriptions['*'] ?? [];
    for (final sub in [...eventSubs, ...wildSubs]) {
      if (sub.isActive) sub.callback(message);
    }
  }

  void clearSubscriptions() {
    for (final subs in _subscriptions.values) {
      for (final sub in subs) sub.cancel();
    }
    _subscriptions.clear();
  }
}
