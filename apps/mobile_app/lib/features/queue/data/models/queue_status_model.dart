import 'package:equatable/equatable.dart';

import '../../domain/entities/queue_status.dart';

/// Data model representing a real-time status update for a queue entry.
///
/// This is not a domain entity but a lightweight DTO pushed by the server
/// (e.g., via WebSocket or SSE) to convey incremental position changes.
class QueueStatusModel extends Equatable {
  /// The queue entry this update belongs to.
  final String entryId;

  /// Updated position in the queue (1-based).
  final int position;

  /// Updated estimated wait time in minutes.
  final int estimatedWaitMinutes;

  /// Updated lifecycle status of the entry.
  final QueueStatus status;

  /// Server-side timestamp of the update.
  final DateTime timestamp;

  /// Optional human-readable message from the server (e.g., "You're next!").
  final String? message;

  /// Creates a [QueueStatusModel].
  const QueueStatusModel({
    required this.entryId,
    required this.position,
    required this.estimatedWaitMinutes,
    required this.status,
    required this.timestamp,
    this.message,
  });

  /// Creates a [QueueStatusModel] from a JSON map.
  factory QueueStatusModel.fromJson(Map<String, dynamic> json) {
    return QueueStatusModel(
      entryId: json['entry_id'] as String,
      position: (json['position'] as num).toInt(),
      estimatedWaitMinutes: (json['estimated_wait_minutes'] as num).toInt(),
      status: QueueStatus.values.firstWhere(
        (s) => s.name == (json['status'] as String),
        orElse: () => QueueStatus.waiting,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      message: json['message'] as String?,
    );
  }

  /// Serialises this model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'entry_id': entryId,
      'position': position,
      'estimated_wait_minutes': estimatedWaitMinutes,
      'status': status.name,
      'timestamp': timestamp.toIso8601String(),
      if (message != null) 'message': message,
    };
  }

  /// Creates a copy of this model with the provided fields replaced.
  QueueStatusModel copyWith({
    String? entryId,
    int? position,
    int? estimatedWaitMinutes,
    QueueStatus? status,
    DateTime? timestamp,
    String? message,
  }) {
    return QueueStatusModel(
      entryId: entryId ?? this.entryId,
      position: position ?? this.position,
      estimatedWaitMinutes: estimatedWaitMinutes ?? this.estimatedWaitMinutes,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props =>
      [entryId, position, estimatedWaitMinutes, status, timestamp, message];
}
