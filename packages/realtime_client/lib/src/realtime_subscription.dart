import 'dart:math';
import 'realtime_message.dart';

/// Handle for a subscription to channel events.
class RealtimeSubscription {
  final String topic;
  final String event;
  final void Function(RealtimeMessage) callback;
  final String _id;
  bool _active = true;

  RealtimeSubscription({
    required this.topic,
    required this.event,
    required this.callback,
  }) : _id = _generateId();

  bool get isActive => _active;
  String get id => _id;

  void cancel() => _active = false;

  static String _generateId() {
    final r = Random.secure();
    const c = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(12, (_) => c[r.nextInt(c.length)]).join();
  }
}
