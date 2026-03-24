import 'package:dartz/dartz.dart';

import 'package:mobile_app/core/error/failures.dart';

import '../entities/app_notification.dart';
import '../entities/notification_category.dart';
import '../entities/notification_preference.dart';

/// Abstract contract for all notification data operations.
///
/// Implementations live in the data layer and may delegate to a remote API,
/// local cache, or a combination of both.
abstract class NotificationRepository {
  /// Fetches a paginated list of notifications.
  ///
  /// [page] is 1-based. [limit] controls page size.
  /// Optionally filter by [category].
  Future<Either<Failure, List<AppNotification>>> getNotifications({
    int page = 1,
    int limit = 20,
    NotificationCategory? category,
  });

  /// Marks the notification identified by [id] as read.
  Future<Either<Failure, Unit>> markAsRead(String id);

  /// Marks every notification belonging to the current user as read.
  Future<Either<Failure, Unit>> markAllAsRead();

  /// Permanently deletes the notification identified by [id].
  Future<Either<Failure, Unit>> deleteNotification(String id);

  /// Permanently deletes all notifications for the current user.
  Future<Either<Failure, Unit>> clearAllNotifications();

  /// Returns the total number of unread notifications.
  Future<Either<Failure, int>> getUnreadCount();

  /// Registers (or refreshes) the device's FCM push token on the backend.
  Future<Either<Failure, Unit>> registerFcmToken(String token);

  /// Retrieves the user's notification delivery preferences.
  Future<Either<Failure, List<NotificationPreference>>> getPreferences();

  /// Persists updated [preferences] to the backend.
  Future<Either<Failure, Unit>> updatePreferences(
    List<NotificationPreference> preferences,
  );

  /// Resolves the in-app navigation route for a given [notification].
  ///
  /// Returns `null` when the notification carries no actionable route.
  Future<Either<Failure, String?>> getActionRoute(AppNotification notification);
}
