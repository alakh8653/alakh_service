import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:rxdart/rxdart.dart';

import 'models/notification_payload.dart';
import 'notification_channels.dart';
import 'local_notification_service.dart';

/// Top-level background message handler — must be a top-level function.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background messages without a running app context.
  // Firebase is already initialized in the main isolate.
}

/// Manages Firebase Cloud Messaging (FCM) initialization, permission requests,
/// token management, and message routing for foreground/background/terminated states.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  final _messageController =
      BehaviorSubject<NotificationPayload>.seeded(NotificationPayload.empty());

  /// Stream of incoming notification payloads (foreground + tapped).
  Stream<NotificationPayload> get onMessage => _messageController.stream;

  String? _fcmToken;

  /// The current FCM device token, or null if not yet retrieved.
  String? get fcmToken => _fcmToken;

  /// Initializes FCM, requests permissions, registers handlers, and fetches token.
  Future<void> initialize() async {
    // Register the background handler before any other Firebase calls.
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await _requestPermission();
    await _fetchToken();
    _registerHandlers();
  }

  /// Requests push notification permission from the user.
  Future<NotificationSettings> _requestPermission() async {
    return _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  /// Retrieves and caches the current FCM registration token.
  Future<void> _fetchToken() async {
    _fcmToken = await _fcm.getToken();

    // Listen for token refreshes (e.g. after app reinstall or token rotation).
    _fcm.onTokenRefresh.listen((newToken) {
      _fcmToken = newToken;
      _onTokenRefreshed(newToken);
    });
  }

  /// Override this to persist the refreshed token to the backend.
  void _onTokenRefreshed(String token) {
    // TODO: POST token to backend /api/v1/users/fcm-token
  }

  /// Registers foreground and interaction handlers.
  void _registerHandlers() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen((message) {
      final payload = _parseRemoteMessage(message);
      _messageController.add(payload);
      LocalNotificationService.instance.show(payload);
    });

    // App opened from a notification (background → foreground tap)
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final payload = _parseRemoteMessage(message);
      _messageController.add(payload);
    });

    // App launched from terminated state via notification tap
    _fcm.getInitialMessage().then((message) {
      if (message != null) {
        final payload = _parseRemoteMessage(message);
        _messageController.add(payload);
      }
    });
  }

  /// Converts a [RemoteMessage] into a typed [NotificationPayload].
  NotificationPayload _parseRemoteMessage(RemoteMessage message) {
    final notification = message.notification;
    return NotificationPayload(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      type: message.data['type'] ?? NotificationPayloadType.system.name,
      title: notification?.title ?? message.data['title'] ?? '',
      body: notification?.body ?? message.data['body'] ?? '',
      data: Map<String, dynamic>.from(message.data),
      imageUrl: notification?.android?.imageUrl ?? message.data['image_url'],
    );
  }

  /// Subscribes the device to an FCM topic (e.g. city-specific promotions).
  Future<void> subscribeToTopic(String topic) => _fcm.subscribeToTopic(topic);

  /// Unsubscribes the device from an FCM topic.
  Future<void> unsubscribeFromTopic(String topic) =>
      _fcm.unsubscribeFromTopic(topic);

  /// Releases resources.
  Future<void> dispose() async {
    await _messageController.close();
  }
}
