import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:mobile_app/core/error/failures.dart';

import '../repositories/notification_repository.dart';

/// Parameters for [DeleteNotificationUseCase].
class DeleteNotificationParams extends Equatable {
  /// ID of the notification to delete.
  final String id;

  /// Creates [DeleteNotificationParams].
  const DeleteNotificationParams({required this.id});

  @override
  List<Object?> get props => [id];
}

/// Permanently deletes a single notification.
class DeleteNotificationUseCase {
  /// Creates [DeleteNotificationUseCase].
  const DeleteNotificationUseCase(this._repository);

  final NotificationRepository _repository;

  /// Executes the use case.
  Future<Either<Failure, Unit>> call(DeleteNotificationParams params) {
    return _repository.deleteNotification(params.id);
  }
}
