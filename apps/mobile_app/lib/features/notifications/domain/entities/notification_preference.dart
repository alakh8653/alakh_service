import 'package:equatable/equatable.dart';

import 'notification_category.dart';

/// Domain entity that stores the user's notification delivery preferences
/// for a single [NotificationCategory].
class NotificationPreference extends Equatable {
  /// The category these preferences apply to.
  final NotificationCategory category;

  /// Whether push notifications are enabled for this category.
  final bool pushEnabled;

  /// Whether email notifications are enabled for this category.
  final bool emailEnabled;

  /// Whether SMS notifications are enabled for this category.
  final bool smsEnabled;

  /// Whether in-app notifications are enabled for this category.
  final bool inAppEnabled;

  /// Creates a [NotificationPreference].
  const NotificationPreference({
    required this.category,
    required this.pushEnabled,
    required this.emailEnabled,
    required this.smsEnabled,
    required this.inAppEnabled,
  });

  /// Factory that creates a fully-enabled preference for the given [category].
  factory NotificationPreference.allEnabled(NotificationCategory category) {
    return NotificationPreference(
      category: category,
      pushEnabled: true,
      emailEnabled: true,
      smsEnabled: true,
      inAppEnabled: true,
    );
  }

  /// Returns a copy of this preference with optional field overrides.
  NotificationPreference copyWith({
    NotificationCategory? category,
    bool? pushEnabled,
    bool? emailEnabled,
    bool? smsEnabled,
    bool? inAppEnabled,
  }) {
    return NotificationPreference(
      category: category ?? this.category,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      smsEnabled: smsEnabled ?? this.smsEnabled,
      inAppEnabled: inAppEnabled ?? this.inAppEnabled,
    );
  }

  @override
  List<Object?> get props => [
        category,
        pushEnabled,
        emailEnabled,
        smsEnabled,
        inAppEnabled,
      ];
}
