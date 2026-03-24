import 'package:equatable/equatable.dart';

/// Domain entity representing a single recent activity event.
///
/// Activities are surfaced in the activity feed on the Dashboard page.
/// Supported [type] values: `booking`, `queue`, `payment`, `review`.
class RecentActivity extends Equatable {
  /// Unique identifier for this activity event.
  final String id;

  /// Category of the activity event.
  ///
  /// One of: `booking`, `queue`, `payment`, `review`.
  final String type;

  /// Short, human-readable title summarising the activity.
  final String title;

  /// Longer description providing additional context.
  final String description;

  /// UTC timestamp when the activity occurred.
  final DateTime timestamp;

  /// Optional deep-link URL to the relevant resource.
  final String? actionUrl;

  const RecentActivity({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
    this.actionUrl,
  });

  @override
  List<Object?> get props => [id, type, title, description, timestamp, actionUrl];
}
