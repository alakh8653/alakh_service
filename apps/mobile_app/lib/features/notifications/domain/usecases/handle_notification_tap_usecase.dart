import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:mobile_app/core/error/failures.dart';

import '../entities/app_notification.dart';
import '../repositories/notification_repository.dart';

/// Parameters for [HandleNotificationTapUseCase].
class HandleNotificationTapParams extends Equatable {
  /// The notification that was tapped.
  final AppNotification notification;

  /// Creates [HandleNotificationTapParams].
  const HandleNotificationTapParams({required this.notification});

  @override
  List<Object?> get props => [notification];
}

/// Resolves the in-app navigation route for the tapped notification.
///
/// Returns a route string (e.g. `/booking/123`) that the presentation layer
/// can pass to `Navigator` or `GoRouter`. Returns `null` when the notification
/// is not actionable.
class HandleNotificationTapUseCase {
  /// Creates [HandleNotificationTapUseCase].
  const HandleNotificationTapUseCase(this._repository);

  final NotificationRepository _repository;

  /// Executes the use case.
  Future<Either<Failure, String?>> call(HandleNotificationTapParams params) {
    return _repository.getActionRoute(params.notification);
  }
}
