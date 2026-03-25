/// Local notification scheduling and management service.
library;

// TODO: Add `flutter_local_notifications` package to pubspec.yaml.

/// Payload attached to a notification.
class NotificationPayload {
  const NotificationPayload({
    required this.id,
    required this.title,
    required this.body,
    this.data = const {},
    this.imageUrl,
  });

  /// Unique notification identifier.
  final int id;
  final String title;
  final String body;

  /// Extra key-value data delivered with the notification.
  final Map<String, String> data;

  /// Optional URL of a large image to display.
  final String? imageUrl;
}

/// Manages local notifications.
///
/// ### Usage:
/// ```dart
/// await NotificationService.instance.init();
/// await NotificationService.instance.show(
///   NotificationPayload(id: 1, title: 'Ready!', body: 'Your order is ready.'),
/// );
/// ```
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  // TODO: final _plugin = FlutterLocalNotificationsPlugin();

  /// Initialises the plugin and creates notification channels (Android).
  Future<void> init() async {
    // TODO:
    // const initSettingsAndroid =
    //     AndroidInitializationSettings('@mipmap/ic_launcher');
    // const initSettingsIos = DarwinInitializationSettings(
    //   requestAlertPermission: true,
    //   requestBadgePermission: true,
    //   requestSoundPermission: true,
    // );
    // await _plugin.initialize(
    //   const InitializationSettings(
    //     android: initSettingsAndroid,
    //     iOS: initSettingsIos,
    //   ),
    //   onDidReceiveNotificationResponse: _onNotificationTapped,
    // );
    // await _createAndroidChannels();
  }

  /// Shows an immediate local notification.
  Future<void> show(NotificationPayload payload) async {
    // TODO:
    // await _plugin.show(
    //   payload.id,
    //   payload.title,
    //   payload.body,
    //   _buildDetails(),
    //   payload: jsonEncode(payload.data),
    // );
    throw UnimplementedError('Add flutter_local_notifications and implement.');
  }

  /// Schedules a notification for delivery at [scheduledDate].
  Future<void> schedule(
    NotificationPayload payload, {
    required DateTime scheduledDate,
  }) async {
    // TODO: Use _plugin.zonedSchedule with tz.TZDateTime.from(scheduledDate, local).
    throw UnimplementedError('Add flutter_local_notifications and implement.');
  }

  /// Cancels a previously shown or scheduled notification by [id].
  Future<void> cancel(int id) async {
    // TODO: await _plugin.cancel(id);
    throw UnimplementedError('Add flutter_local_notifications and implement.');
  }

  /// Cancels all notifications.
  Future<void> cancelAll() async {
    // TODO: await _plugin.cancelAll();
    throw UnimplementedError('Add flutter_local_notifications and implement.');
  }

  // TODO: Add _createAndroidChannels, _buildDetails, _onNotificationTapped.
}
