import 'models/notification_payload.dart';

/// Routes incoming notifications to the appropriate screen or action
/// based on the notification [type] and attached [data].
///
/// Implement [NotificationRouter] and register it via [NotificationHandler.setRouter]
/// to connect deep-linking logic from your navigation layer.
abstract class NotificationRouter {
  /// Called when a notification of the given [payload] is tapped.
  void route(NotificationPayload payload);
}

/// Central handler that delegates notification routing to a registered [NotificationRouter].
class NotificationHandler {
  NotificationHandler._();
  static final NotificationHandler instance = NotificationHandler._();

  NotificationRouter? _router;

  /// Registers the app-level router that handles navigation on notification tap.
  void setRouter(NotificationRouter router) {
    _router = router;
  }

  /// Processes an incoming notification payload and routes it accordingly.
  void handle(NotificationPayload payload) {
    if (payload.isEmpty) return;
    _router?.route(payload);
  }

  /// Returns the target route path for a given notification type and data.
  ///
  /// Override logic in your [NotificationRouter] implementation to map each
  /// [NotificationPayloadType] to a specific screen path in your router.
  static String? routeForPayload(NotificationPayload payload) {
    switch (payload.notificationType) {
      case NotificationPayloadType.booking:
        final bookingId = payload.data['booking_id'];
        return bookingId != null ? '/bookings/$bookingId' : '/bookings';
      case NotificationPayloadType.chat:
        final conversationId = payload.data['conversation_id'];
        return conversationId != null ? '/chat/$conversationId' : '/chat';
      case NotificationPayloadType.payment:
        return '/payments';
      case NotificationPayloadType.queue:
        return '/queue';
      case NotificationPayloadType.dispatch:
        final dispatchId = payload.data['dispatch_id'];
        return dispatchId != null ? '/dispatch/$dispatchId' : null;
      case NotificationPayloadType.promotion:
        return '/promotions';
      case NotificationPayloadType.system:
      default:
        return null;
    }
  }
}
