import 'package:dartz/dartz.dart';

import 'package:mobile_app/core/error/failures.dart';

import '../repositories/notification_repository.dart';

/// Marks all of the current user's notifications as read.
class MarkAllReadUseCase {
  /// Creates [MarkAllReadUseCase].
  const MarkAllReadUseCase(this._repository);

  final NotificationRepository _repository;

  /// Executes the use case. Takes no parameters.
  Future<Either<Failure, Unit>> call() {
    return _repository.markAllAsRead();
  }
}
