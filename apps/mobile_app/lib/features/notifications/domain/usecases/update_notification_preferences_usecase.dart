import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:mobile_app/core/error/failures.dart';

import '../entities/notification_preference.dart';
import '../repositories/notification_repository.dart';

/// Parameters for [UpdateNotificationPreferencesUseCase].
class UpdateNotificationPreferencesParams extends Equatable {
  /// The full list of updated preferences to persist.
  final List<NotificationPreference> preferences;

  /// Creates [UpdateNotificationPreferencesParams].
  const UpdateNotificationPreferencesParams({required this.preferences});

  @override
  List<Object?> get props => [preferences];
}

/// Persists updated notification delivery preferences to the backend.
class UpdateNotificationPreferencesUseCase {
  /// Creates [UpdateNotificationPreferencesUseCase].
  const UpdateNotificationPreferencesUseCase(this._repository);

  final NotificationRepository _repository;

  /// Executes the use case.
  Future<Either<Failure, Unit>> call(
    UpdateNotificationPreferencesParams params,
  ) {
    return _repository.updatePreferences(params.preferences);
  }
}
