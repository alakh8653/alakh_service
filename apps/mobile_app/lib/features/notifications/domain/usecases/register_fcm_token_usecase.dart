import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:mobile_app/core/error/failures.dart';

import '../repositories/notification_repository.dart';

/// Parameters for [RegisterFcmTokenUseCase].
class RegisterFcmTokenParams extends Equatable {
  /// The FCM device token to register.
  final String token;

  /// Creates [RegisterFcmTokenParams].
  const RegisterFcmTokenParams({required this.token});

  @override
  List<Object?> get props => [token];
}

/// Sends the device's FCM push token to the backend so it can deliver
/// push notifications to this device.
class RegisterFcmTokenUseCase {
  /// Creates [RegisterFcmTokenUseCase].
  const RegisterFcmTokenUseCase(this._repository);

  final NotificationRepository _repository;

  /// Executes the use case.
  Future<Either<Failure, Unit>> call(RegisterFcmTokenParams params) {
    return _repository.registerFcmToken(params.token);
  }
}
