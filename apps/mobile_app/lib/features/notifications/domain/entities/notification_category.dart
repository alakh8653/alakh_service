/// High-level category that groups notifications by intent.
enum NotificationCategory {
  /// Notifications triggered by user actions (bookings, payments, etc.).
  transactional,

  /// Marketing or promotional notifications.
  promotional,

  /// Notifications involving social interaction (chat, reviews, etc.).
  social,

  /// Platform / system-level notifications.
  system,
}

/// Extension helpers for [NotificationCategory].
extension NotificationCategoryX on NotificationCategory {
  /// Human-readable label shown in UI.
  String get label {
    switch (this) {
      case NotificationCategory.transactional:
        return 'Transactional';
      case NotificationCategory.promotional:
        return 'Promotional';
      case NotificationCategory.social:
        return 'Social';
      case NotificationCategory.system:
        return 'System';
    }
  }

  /// Short description used on the preferences screen.
  String get description {
    switch (this) {
      case NotificationCategory.transactional:
        return 'Bookings, payments, dispatch and queue updates.';
      case NotificationCategory.promotional:
        return 'Deals, offers and news from the platform.';
      case NotificationCategory.social:
        return 'Chat messages, reviews and trust events.';
      case NotificationCategory.system:
        return 'Account, security and platform announcements.';
    }
  }

  /// Returns the string key used in JSON payloads.
  String get value => name;

  /// Parses a [NotificationCategory] from a JSON string,
  /// defaulting to [system].
  static NotificationCategory fromValue(String? value) {
    return NotificationCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => NotificationCategory.system,
    );
  }
}
