/// Channel subscription abstraction for the realtime service.
///
/// A [RealtimeChannel] represents a logical subscription to a named topic
/// (e.g. `shop:123`, `user:456`) and exposes a stream of typed events.
library realtime_channel;

import 'dart:async';

import 'realtime_events.dart';

/// Status of a [RealtimeChannel] subscription.
enum ChannelStatus {
  /// Subscription has been requested but not yet acknowledged by the server.
  subscribing,

  /// The channel is active and receiving events.
  subscribed,

  /// The channel has been unsubscribed and will no longer emit events.
  unsubscribed,

  /// An error occurred during subscription.
  error,
}

/// Represents a subscription to a named realtime topic / channel.
///
/// Usage:
/// ```dart
/// final channel = realtimeService.channel('shop:123');
/// channel.on(RealtimeEventNames.queueUpdated).listen((event) {
///   final e = event as QueueUpdatedEvent;
///   print('Queue length: ${e.queueLength}');
/// });
/// await channel.subscribe();
/// ```
class RealtimeChannel {
  RealtimeChannel({
    required this.name,
    required Stream<RealtimeEvent> eventStream,
  }) : _rawStream = eventStream;

  /// The channel topic name (e.g. `shop:123`).
  final String name;

  final Stream<RealtimeEvent> _rawStream;
  final StreamController<ChannelStatus> _statusController =
      StreamController<ChannelStatus>.broadcast();

  ChannelStatus _status = ChannelStatus.unsubscribed;

  /// Current subscription status.
  ChannelStatus get status => _status;

  /// Stream of status changes.
  Stream<ChannelStatus> get onStatusChange => _statusController.stream;

  /// Filtered stream that emits only events matching [eventName].
  ///
  /// Example:
  /// ```dart
  /// channel.on(RealtimeEventNames.queueUpdated).listen(handleQueueUpdate);
  /// ```
  Stream<RealtimeEvent> on(String eventName) =>
      _rawStream.where((e) => e.eventName == eventName);

  /// Filtered stream typed to a specific [RealtimeEvent] subtype.
  ///
  /// Example:
  /// ```dart
  /// channel.onType<QueueUpdatedEvent>().listen((e) => print(e.queueLength));
  /// ```
  Stream<T> onType<T extends RealtimeEvent>() =>
      _rawStream.whereType<T>();

  /// Subscribes to this channel.
  ///
  /// Returns a [Future] that completes once the subscription is acknowledged.
  Future<void> subscribe() async {
    _updateStatus(ChannelStatus.subscribing);
    // TODO: Send subscribe message via the underlying WebSocket transport
    // and await server acknowledgement before marking as subscribed.
    _updateStatus(ChannelStatus.subscribed);
  }

  /// Unsubscribes from this channel and closes the status stream.
  Future<void> unsubscribe() async {
    // TODO: Send unsubscribe message to server.
    _updateStatus(ChannelStatus.unsubscribed);
    await _statusController.close();
  }

  void _updateStatus(ChannelStatus status) {
    _status = status;
    if (!_statusController.isClosed) {
      _statusController.add(status);
    }
  }

  @override
  String toString() => 'RealtimeChannel(name: $name, status: $_status)';
}
