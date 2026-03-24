import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Defines Android notification channel IDs and their display metadata.
class NotificationChannels {
  NotificationChannels._();

  // Channel IDs
  static const String bookingsChannelId = 'bookings';
  static const String chatChannelId = 'chat';
  static const String queueChannelId = 'queue';
  static const String paymentsChannelId = 'payments';
  static const String promotionsChannelId = 'promotions';
  static const String defaultChannelId = 'general';

  /// All Android notification channels used by the app.
  static final List<AndroidNotificationChannel> androidChannels = [
    const AndroidNotificationChannel(
      bookingsChannelId,
      'Bookings',
      description: 'Booking confirmations, updates, and cancellations.',
      importance: Importance.high,
    ),
    const AndroidNotificationChannel(
      chatChannelId,
      'Chat',
      description: 'New messages from providers and support.',
      importance: Importance.high,
    ),
    const AndroidNotificationChannel(
      queueChannelId,
      'Queue Updates',
      description: 'Your position in the service queue.',
      importance: Importance.defaultImportance,
    ),
    const AndroidNotificationChannel(
      paymentsChannelId,
      'Payments',
      description: 'Payment confirmations and receipts.',
      importance: Importance.high,
    ),
    const AndroidNotificationChannel(
      promotionsChannelId,
      'Offers & Promotions',
      description: 'Exclusive deals and promotional offers.',
      importance: Importance.low,
    ),
    const AndroidNotificationChannel(
      defaultChannelId,
      'General',
      description: 'General app notifications.',
      importance: Importance.defaultImportance,
    ),
  ];

  /// Returns the channel ID corresponding to a notification type string.
  static String channelIdForType(String type) {
    switch (type) {
      case 'booking':
        return bookingsChannelId;
      case 'chat':
        return chatChannelId;
      case 'queue':
        return queueChannelId;
      case 'payment':
        return paymentsChannelId;
      case 'promotion':
        return promotionsChannelId;
      default:
        return defaultChannelId;
    }
  }

  /// Returns the display name for a notification channel by type.
  static String channelNameForType(String type) {
    switch (type) {
      case 'booking':
        return 'Bookings';
      case 'chat':
        return 'Chat';
      case 'queue':
        return 'Queue Updates';
      case 'payment':
        return 'Payments';
      case 'promotion':
        return 'Offers & Promotions';
      default:
        return 'General';
    }
  }
}
