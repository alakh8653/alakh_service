import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'models/notification_payload.dart';
import 'notification_channels.dart';

/// Handles the display of local notifications using [flutter_local_notifications].
///
/// Supports platform-specific channels on Android and notification categories
/// on iOS/macOS.
class LocalNotificationService {
  LocalNotificationService._();
  static final LocalNotificationService instance = LocalNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initializes the plugin with Android/iOS settings and creates Android channels.
  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(initSettings);

    if (Platform.isAndroid) {
      await _createAndroidChannels();
    }

    _initialized = true;
  }

  /// Creates the predefined Android notification channels.
  Future<void> _createAndroidChannels() async {
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) return;

    for (final channel in NotificationChannels.androidChannels) {
      await androidPlugin.createNotificationChannel(channel);
    }
  }

  /// Displays a local notification for the given [payload].
  Future<void> show(NotificationPayload payload) async {
    if (!_initialized) await initialize();

    final androidDetails = AndroidNotificationDetails(
      NotificationChannels.channelIdForType(payload.type),
      NotificationChannels.channelNameForType(payload.type),
      importance: Importance.high,
      priority: Priority.high,
      largeIcon: payload.imageUrl != null
          ? DrawableResourceAndroidBitmap(payload.imageUrl!)
          : null,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      payload.hashCode,
      payload.title,
      payload.body,
      details,
      payload: payload.id,
    );
  }

  /// Cancels a notification by [id].
  Future<void> cancel(int id) => _plugin.cancel(id);

  /// Cancels all active local notifications.
  Future<void> cancelAll() => _plugin.cancelAll();

  /// Returns the notification that launched the app, if any.
  Future<NotificationAppLaunchDetails?> getAppLaunchDetails() =>
      _plugin.getNotificationAppLaunchDetails();
}
