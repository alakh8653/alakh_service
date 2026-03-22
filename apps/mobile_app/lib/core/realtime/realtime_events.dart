/// Real-time event type constants and event model classes.
///
/// Every event flowing through the WebSocket connection is represented by a
/// typed [RealtimeEvent] subclass so the application can pattern-match safely.
library realtime_events;

// ── Event names ───────────────────────────────────────────────────────────────

/// String constants for all WebSocket event names.
abstract final class RealtimeEventNames {
  RealtimeEventNames._();

  // Connection lifecycle
  static const String connected = 'connected';
  static const String disconnected = 'disconnected';
  static const String error = 'error';

  // Queue
  static const String queueUpdated = 'queue.updated';
  static const String queuePositionChanged = 'queue.position_changed';
  static const String queueJoined = 'queue.joined';
  static const String queueLeft = 'queue.left';

  // Booking
  static const String bookingCreated = 'booking.created';
  static const String bookingConfirmed = 'booking.confirmed';
  static const String bookingCancelled = 'booking.cancelled';
  static const String bookingCompleted = 'booking.completed';

  // Job / dispatch
  static const String jobAssigned = 'job.assigned';
  static const String jobStarted = 'job.started';
  static const String jobCompleted = 'job.completed';

  // Tracking
  static const String locationUpdated = 'location.updated';
  static const String etaUpdated = 'eta.updated';

  // Chat
  static const String messageReceived = 'chat.message_received';
  static const String messageRead = 'chat.message_read';
  static const String userTyping = 'chat.user_typing';

  // Notifications
  static const String pushNotification = 'notification.push';

  // Payment
  static const String paymentUpdated = 'payment.updated';
}

// ── Base event ────────────────────────────────────────────────────────────────

/// Base class for all incoming WebSocket events.
sealed class RealtimeEvent {
  const RealtimeEvent({required this.eventName, required this.timestamp});

  /// The event name string (see [RealtimeEventNames]).
  final String eventName;

  /// UTC timestamp when the event was emitted.
  final DateTime timestamp;

  /// Factory constructor that deserialises a raw JSON payload.
  factory RealtimeEvent.fromJson(Map<String, dynamic> json) {
    final event = json['event'] as String? ?? '';
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final ts = DateTime.tryParse(json['timestamp'] as String? ?? '') ??
        DateTime.now().toUtc();

    return switch (event) {
      RealtimeEventNames.queueUpdated =>
        QueueUpdatedEvent.fromJson(data, ts),
      RealtimeEventNames.bookingCreated =>
        BookingEvent.fromJson(event, data, ts),
      RealtimeEventNames.bookingConfirmed =>
        BookingEvent.fromJson(event, data, ts),
      RealtimeEventNames.bookingCancelled =>
        BookingEvent.fromJson(event, data, ts),
      RealtimeEventNames.bookingCompleted =>
        BookingEvent.fromJson(event, data, ts),
      RealtimeEventNames.locationUpdated =>
        LocationUpdatedEvent.fromJson(data, ts),
      RealtimeEventNames.messageReceived =>
        ChatMessageEvent.fromJson(data, ts),
      RealtimeEventNames.pushNotification =>
        PushNotificationEvent.fromJson(data, ts),
      _ => RawRealtimeEvent(eventName: event, data: data, timestamp: ts),
    };
  }
}

// ── Concrete event types ──────────────────────────────────────────────────────

/// Emitted when the queue size or estimated wait time changes.
final class QueueUpdatedEvent extends RealtimeEvent {
  const QueueUpdatedEvent({
    required super.timestamp,
    required this.shopId,
    required this.queueLength,
    required this.estimatedWaitMinutes,
  }) : super(eventName: RealtimeEventNames.queueUpdated);

  factory QueueUpdatedEvent.fromJson(
    Map<String, dynamic> data,
    DateTime ts,
  ) =>
      QueueUpdatedEvent(
        timestamp: ts,
        shopId: data['shop_id'] as String? ?? '',
        queueLength: data['queue_length'] as int? ?? 0,
        estimatedWaitMinutes: data['estimated_wait_minutes'] as int? ?? 0,
      );

  final String shopId;
  final int queueLength;
  final int estimatedWaitMinutes;
}

/// Emitted for any booking lifecycle change.
final class BookingEvent extends RealtimeEvent {
  const BookingEvent({
    required super.eventName,
    required super.timestamp,
    required this.bookingId,
    required this.status,
  });

  factory BookingEvent.fromJson(
    String event,
    Map<String, dynamic> data,
    DateTime ts,
  ) =>
      BookingEvent(
        eventName: event,
        timestamp: ts,
        bookingId: data['booking_id'] as String? ?? '',
        status: data['status'] as String? ?? '',
      );

  final String bookingId;
  final String status;
}

/// Emitted when a staff member or vehicle location changes.
final class LocationUpdatedEvent extends RealtimeEvent {
  const LocationUpdatedEvent({
    required super.timestamp,
    required this.entityId,
    required this.entityType,
    required this.latitude,
    required this.longitude,
  }) : super(eventName: RealtimeEventNames.locationUpdated);

  factory LocationUpdatedEvent.fromJson(
    Map<String, dynamic> data,
    DateTime ts,
  ) =>
      LocationUpdatedEvent(
        timestamp: ts,
        entityId: data['entity_id'] as String? ?? '',
        entityType: data['entity_type'] as String? ?? '',
        latitude: (data['lat'] as num?)?.toDouble() ?? 0.0,
        longitude: (data['lng'] as num?)?.toDouble() ?? 0.0,
      );

  final String entityId;
  final String entityType;
  final double latitude;
  final double longitude;
}

/// Emitted when a chat message arrives.
final class ChatMessageEvent extends RealtimeEvent {
  const ChatMessageEvent({
    required super.timestamp,
    required this.roomId,
    required this.messageId,
    required this.senderId,
    required this.content,
  }) : super(eventName: RealtimeEventNames.messageReceived);

  factory ChatMessageEvent.fromJson(
    Map<String, dynamic> data,
    DateTime ts,
  ) =>
      ChatMessageEvent(
        timestamp: ts,
        roomId: data['room_id'] as String? ?? '',
        messageId: data['message_id'] as String? ?? '',
        senderId: data['sender_id'] as String? ?? '',
        content: data['content'] as String? ?? '',
      );

  final String roomId;
  final String messageId;
  final String senderId;
  final String content;
}

/// Emitted for push-style in-app notifications.
final class PushNotificationEvent extends RealtimeEvent {
  const PushNotificationEvent({
    required super.timestamp,
    required this.notificationId,
    required this.title,
    required this.body,
    this.data,
  }) : super(eventName: RealtimeEventNames.pushNotification);

  factory PushNotificationEvent.fromJson(
    Map<String, dynamic> data,
    DateTime ts,
  ) =>
      PushNotificationEvent(
        timestamp: ts,
        notificationId: data['notification_id'] as String? ?? '',
        title: data['title'] as String? ?? '',
        body: data['body'] as String? ?? '',
        data: data['data'] as Map<String, dynamic>?,
      );

  final String notificationId;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
}

/// Catch-all for any unrecognised event type.
final class RawRealtimeEvent extends RealtimeEvent {
  const RawRealtimeEvent({
    required super.eventName,
    required super.timestamp,
    required this.data,
  });

  final Map<String, dynamic> data;
}
