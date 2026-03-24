import 'package:equatable/equatable.dart';

import 'queue_status.dart';

/// Domain entity representing a single entry (ticket) in a queue.
class QueueEntry extends Equatable {
  /// Unique identifier for this entry.
  final String id;

  /// Identifier of the user who joined the queue.
  final String userId;

  /// Identifier of the queue this entry belongs to.
  final String queueId;

  /// Current position in the queue (1-based).
  final int position;

  /// Timestamp at which the user joined the queue.
  final DateTime joinedAt;

  /// Estimated time remaining before this entry is served.
  final Duration estimatedWaitTime;

  /// Current lifecycle status of this queue entry.
  final QueueStatus status;

  /// Creates a [QueueEntry] entity.
  const QueueEntry({
    required this.id,
    required this.userId,
    required this.queueId,
    required this.position,
    required this.joinedAt,
    required this.estimatedWaitTime,
    required this.status,
  });

  /// Whether this entry is still active and waiting to be served.
  bool get isActive => status.isActive;

  /// Estimated time at which the user will be served.
  DateTime get estimatedServeTime => joinedAt.add(estimatedWaitTime);

  @override
  List<Object?> get props => [
        id,
        userId,
        queueId,
        position,
        joinedAt,
        estimatedWaitTime,
        status,
      ];
}
