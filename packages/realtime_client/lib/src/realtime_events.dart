/// Centralised socket event name constants used across the monorepo.
class RealtimeEvents {
  RealtimeEvents._();

  // Queue management
  static const String queueUpdate = 'queue:update';
  static const String queueJoin = 'queue:join';
  static const String queueLeave = 'queue:leave';
  static const String queuePosition = 'queue:position';

  // Dispatch / delivery tracking
  static const String dispatchUpdate = 'dispatch:update';
  static const String dispatchAssigned = 'dispatch:assigned';
  static const String dispatchPickedUp = 'dispatch:picked_up';
  static const String dispatchDelivered = 'dispatch:delivered';

  // Location
  static const String locationUpdate = 'location:update';
  static const String driverLocationUpdate = 'driver:location_update';

  // Chat
  static const String chatMessage = 'chat:message';
  static const String chatRead = 'chat:read';
  static const String chatTyping = 'chat:typing';

  // Booking
  static const String bookingConfirmed = 'booking:confirmed';
  static const String bookingCancelled = 'booking:cancelled';
  static const String bookingStatusChanged = 'booking:status_changed';

  // Presence
  static const String userOnline = 'user:online';
  static const String userOffline = 'user:offline';
}
