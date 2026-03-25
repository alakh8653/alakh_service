import '../realtime_service.dart';

class QueueUpdate {
  const QueueUpdate({
    required this.shopId,
    required this.position,
    required this.estimatedWaitMinutes,
    required this.totalInQueue,
  });

  final String shopId;
  final int position;
  final int estimatedWaitMinutes;
  final int totalInQueue;

  factory QueueUpdate.fromMap(Map<String, dynamic> map) => QueueUpdate(
        shopId: map['shopId'] as String,
        position: map['position'] as int,
        estimatedWaitMinutes: map['estimatedWaitMinutes'] as int,
        totalInQueue: map['totalInQueue'] as int,
      );
}

class QueueChannel {
  QueueChannel({required RealtimeService realtimeService})
      : _service = realtimeService;

  final RealtimeService _service;

  static const String _queueUpdateEvent = 'queue:update';
  static const String _joinQueueEvent = 'queue:join';
  static const String _leaveQueueEvent = 'queue:leave';

  Stream<QueueUpdate> get queueUpdates => _service.on<QueueUpdate>(
        _queueUpdateEvent,
        (data) => QueueUpdate.fromMap(data as Map<String, dynamic>),
      );

  void joinQueue(String shopId) =>
      _service.emit(_joinQueueEvent, {'shopId': shopId});

  void leaveQueue(String shopId) =>
      _service.emit(_leaveQueueEvent, {'shopId': shopId});

  void unsubscribe() => _service.off(_queueUpdateEvent);
}
