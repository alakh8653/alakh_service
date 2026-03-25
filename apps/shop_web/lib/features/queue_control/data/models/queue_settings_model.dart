import 'package:shop_web/features/queue_control/domain/entities/queue_settings.dart';

/// Data-transfer object for queue configuration returned by the API.
class QueueSettingsModel {
  QueueSettingsModel({
    required this.isActive,
    required this.maxQueueSize,
    required this.avgServiceTimeMinutes,
    required this.autoAssignStaff,
    required this.allowOnlineJoining,
    this.pauseReason,
    this.pausedAt,
  });

  final bool isActive;
  final int maxQueueSize;
  final int avgServiceTimeMinutes;
  final bool autoAssignStaff;
  final bool allowOnlineJoining;
  final String? pauseReason;
  final DateTime? pausedAt;

  /// Deserialises a JSON map from the API response.
  factory QueueSettingsModel.fromJson(Map<String, dynamic> json) {
    return QueueSettingsModel(
      isActive: json['is_active'] as bool,
      maxQueueSize: json['max_queue_size'] as int,
      avgServiceTimeMinutes: json['avg_service_time_minutes'] as int,
      autoAssignStaff: json['auto_assign_staff'] as bool,
      allowOnlineJoining: json['allow_online_joining'] as bool,
      pauseReason: json['pause_reason'] as String?,
      pausedAt: json['paused_at'] != null
          ? DateTime.parse(json['paused_at'] as String)
          : null,
    );
  }

  /// Serialises this model to a JSON map for API requests.
  Map<String, dynamic> toJson() => {
        'is_active': isActive,
        'max_queue_size': maxQueueSize,
        'avg_service_time_minutes': avgServiceTimeMinutes,
        'auto_assign_staff': autoAssignStaff,
        'allow_online_joining': allowOnlineJoining,
        if (pauseReason != null) 'pause_reason': pauseReason,
        if (pausedAt != null) 'paused_at': pausedAt!.toIso8601String(),
      };

  /// Converts this model to a domain [QueueSettings] entity.
  QueueSettings toEntity() => QueueSettings(
        isActive: isActive,
        maxQueueSize: maxQueueSize,
        avgServiceTimeMinutes: avgServiceTimeMinutes,
        autoAssignStaff: autoAssignStaff,
        allowOnlineJoining: allowOnlineJoining,
        pauseReason: pauseReason,
        pausedAt: pausedAt,
      );

  /// Creates a [QueueSettingsModel] from a domain [QueueSettings] entity.
  factory QueueSettingsModel.fromEntity(QueueSettings entity) {
    return QueueSettingsModel(
      isActive: entity.isActive,
      maxQueueSize: entity.maxQueueSize,
      avgServiceTimeMinutes: entity.avgServiceTimeMinutes,
      autoAssignStaff: entity.autoAssignStaff,
      allowOnlineJoining: entity.allowOnlineJoining,
      pauseReason: entity.pauseReason,
      pausedAt: entity.pausedAt,
    );
  }
}
