import 'package:dartz/dartz.dart';

import 'package:mobile_app/core/error/failures.dart';

import '../repositories/notification_repository.dart';

/// Permanently deletes all notifications for the current user.
class ClearAllNotificationsUseCase {
  /// Creates [ClearAllNotificationsUseCase].
  const ClearAllNotificationsUseCase(this._repository);

  final NotificationRepository _repository;

  /// Executes the use case. Takes no parameters.
  Future<Either<Failure, Unit>> call() {
    return _repository.clearAllNotifications();
  }
}
