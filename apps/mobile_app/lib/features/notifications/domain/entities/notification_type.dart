/// Defines the type of notification, used to categorise and route notifications.
enum NotificationType {
  /// A notification related to a service booking (created, confirmed, cancelled).
  booking,

  /// A notification about queue position changes.
  queue,

  /// A notification related to a payment event (received, failed, refunded).
  payment,

  /// A notification about dispatch / en-route status.
  dispatch,

  /// A notification from in-app chat.
  chat,

  /// A promotional or marketing notification.
  promotion,

  /// A notification triggered by a new review.
  review,

  /// A notification about an open dispute.
  dispute,

  /// A generic system-level notification.
  system,

  /// A notification related to trust or verification events.
  trust,
}

/// Extension helpers for [NotificationType].
extension NotificationTypeX on NotificationType {
  /// Human-readable display label.
  String get label {
    switch (this) {
      case NotificationType.booking:
        return 'Booking';
      case NotificationType.queue:
        return 'Queue';
      case NotificationType.payment:
        return 'Payment';
      case NotificationType.dispatch:
        return 'Dispatch';
      case NotificationType.chat:
        return 'Chat';
      case NotificationType.promotion:
        return 'Promotion';
      case NotificationType.review:
        return 'Review';
      case NotificationType.dispute:
        return 'Dispute';
      case NotificationType.system:
        return 'System';
      case NotificationType.trust:
        return 'Trust';
    }
  }

  /// Returns the string key used in JSON payloads.
  String get value => name;

  /// Parses a [NotificationType] from a JSON string, defaulting to [system].
  static NotificationType fromValue(String? value) {
    return NotificationType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => NotificationType.system,
    );
  }
}
