import 'package:equatable/equatable.dart';

/// Configuration settings for the service queue.
class QueueSettings extends Equatable {
  const QueueSettings({
    required this.isActive,
    required this.maxQueueSize,
    required this.avgServiceTimeMinutes,
    required this.autoAssignStaff,
    required this.allowOnlineJoining,
    this.pauseReason,
    this.pausedAt,
  });

  /// Whether the queue is currently accepting new entries.
  final bool isActive;

  /// Maximum number of customers allowed in queue simultaneously.
  final int maxQueueSize;

  /// Average minutes required to service one customer.
  final int avgServiceTimeMinutes;

  /// Whether staff should be automatically assigned to queue items.
  final bool autoAssignStaff;

  /// Whether customers can join the queue via online/mobile channels.
  final bool allowOnlineJoining;

  /// Reason provided when the queue was paused.
  final String? pauseReason;

  /// Timestamp when the queue was paused.
  final DateTime? pausedAt;

  bool get isPaused => !isActive;

  QueueSettings copyWith({
    bool? isActive,
    int? maxQueueSize,
    int? avgServiceTimeMinutes,
    bool? autoAssignStaff,
    bool? allowOnlineJoining,
    String? pauseReason,
    DateTime? pausedAt,
  }) {
    return QueueSettings(
      isActive: isActive ?? this.isActive,
      maxQueueSize: maxQueueSize ?? this.maxQueueSize,
      avgServiceTimeMinutes:
          avgServiceTimeMinutes ?? this.avgServiceTimeMinutes,
      autoAssignStaff: autoAssignStaff ?? this.autoAssignStaff,
      allowOnlineJoining: allowOnlineJoining ?? this.allowOnlineJoining,
      pauseReason: pauseReason ?? this.pauseReason,
      pausedAt: pausedAt ?? this.pausedAt,
    );
  }

  /// Returns a default/empty settings configuration.
  factory QueueSettings.empty() => const QueueSettings(
        isActive: true,
        maxQueueSize: 50,
        avgServiceTimeMinutes: 15,
        autoAssignStaff: false,
        allowOnlineJoining: true,
      );

  @override
  List<Object?> get props => [
        isActive,
        maxQueueSize,
        avgServiceTimeMinutes,
        autoAssignStaff,
        allowOnlineJoining,
        pauseReason,
        pausedAt,
      ];
}
