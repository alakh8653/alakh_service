import 'package:shop_web/features/dashboard/domain/entities/recent_activity.dart';

/// Data model for a recent activity event returned from the API.
///
/// Activity types include: `booking`, `queue`, `payment`, and `review`.
/// Maps to the [RecentActivity] domain entity.
class RecentActivityModel {
  /// Unique identifier for this activity event.
  final String id;

  /// Category of the activity: `booking`, `queue`, `payment`, or `review`.
  final String type;

  /// Short human-readable title for the activity.
  final String title;

  /// Longer description providing context for the activity.
  final String description;

  /// UTC timestamp when the activity occurred.
  final DateTime timestamp;

  /// Optional deep-link URL to the relevant resource in the app.
  final String? actionUrl;

  const RecentActivityModel({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
    this.actionUrl,
  });

  /// Creates a [RecentActivityModel] from a JSON map.
  factory RecentActivityModel.fromJson(Map<String, dynamic> json) {
    return RecentActivityModel(
      id: (json['id'] as String?) ?? '',
      type: (json['type'] as String?) ?? 'booking',
      title: (json['title'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      actionUrl: json['action_url'] as String?,
    );
  }

  /// Serializes this model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      if (actionUrl != null) 'action_url': actionUrl,
    };
  }

  /// Converts this model to the [RecentActivity] domain entity.
  RecentActivity toEntity() {
    return RecentActivity(
      id: id,
      type: type,
      title: title,
      description: description,
      timestamp: timestamp,
      actionUrl: actionUrl,
    );
  }
}
