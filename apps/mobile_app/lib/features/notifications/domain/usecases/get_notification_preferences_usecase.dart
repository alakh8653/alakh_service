import 'package:dartz/dartz.dart';

import 'package:mobile_app/core/error/failures.dart';

import '../entities/notification_preference.dart';
import '../repositories/notification_repository.dart';

/// Retrieves the user's notification delivery preferences from the backend.
class GetNotificationPreferencesUseCase {
  /// Creates [GetNotificationPreferencesUseCase].
  const GetNotificationPreferencesUseCase(this._repository);

  final NotificationRepository _repository;

  /// Executes the use case. Takes no parameters.
  Future<Either<Failure, List<NotificationPreference>>> call() {
    return _repository.getPreferences();
  }
}
