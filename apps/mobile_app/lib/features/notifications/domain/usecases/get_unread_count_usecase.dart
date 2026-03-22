import 'package:dartz/dartz.dart';

import 'package:mobile_app/core/error/failures.dart';

import '../repositories/notification_repository.dart';

/// Returns the total count of unread notifications for the current user.
class GetUnreadCountUseCase {
  /// Creates [GetUnreadCountUseCase].
  const GetUnreadCountUseCase(this._repository);

  final NotificationRepository _repository;

  /// Executes the use case. Takes no parameters.
  Future<Either<Failure, int>> call() {
    return _repository.getUnreadCount();
  }
}
