import '../../domain/entities/queue_entry.dart';
import '../../domain/entities/queue_status.dart';

/// Data model that extends [QueueEntry] with JSON serialisation support.
class QueueEntryModel extends QueueEntry {
  /// Creates a [QueueEntryModel].
  const QueueEntryModel({
    required super.id,
    required super.userId,
    required super.queueId,
    required super.position,
    required super.joinedAt,
    required super.estimatedWaitTime,
    required super.status,
  });

  /// Creates a [QueueEntryModel] from a JSON map.
  ///
  /// - [joined_at] must be an ISO-8601 string.
  /// - [estimated_wait_minutes] is a number representing minutes.
  /// - [status] must match a [QueueStatus] name (e.g. `"waiting"`).
  factory QueueEntryModel.fromJson(Map<String, dynamic> json) {
    return QueueEntryModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      queueId: json['queue_id'] as String,
      position: (json['position'] as num).toInt(),
      joinedAt: DateTime.parse(json['joined_at'] as String),
      estimatedWaitTime: Duration(
        minutes: (json['estimated_wait_minutes'] as num).toInt(),
      ),
      status: QueueStatus.values.firstWhere(
        (s) => s.name == (json['status'] as String),
        orElse: () => QueueStatus.waiting,
      ),
    );
  }

  /// Serialises this model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'queue_id': queueId,
      'position': position,
      'joined_at': joinedAt.toIso8601String(),
      'estimated_wait_minutes': estimatedWaitTime.inMinutes,
      'status': status.name,
    };
  }

  /// Creates a copy of this model with the provided fields replaced.
  QueueEntryModel copyWith({
    String? id,
    String? userId,
    String? queueId,
    int? position,
    DateTime? joinedAt,
    Duration? estimatedWaitTime,
    QueueStatus? status,
  }) {
    return QueueEntryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      queueId: queueId ?? this.queueId,
      position: position ?? this.position,
      joinedAt: joinedAt ?? this.joinedAt,
      estimatedWaitTime: estimatedWaitTime ?? this.estimatedWaitTime,
      status: status ?? this.status,
    );
  }

  /// Creates a [QueueEntryModel] from its domain [QueueEntry] counterpart.
  factory QueueEntryModel.fromEntity(QueueEntry entry) {
    return QueueEntryModel(
      id: entry.id,
      userId: entry.userId,
      queueId: entry.queueId,
      position: entry.position,
      joinedAt: entry.joinedAt,
      estimatedWaitTime: entry.estimatedWaitTime,
      status: entry.status,
    );
  }
}
