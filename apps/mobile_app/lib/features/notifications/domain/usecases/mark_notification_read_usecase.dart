import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:mobile_app/core/error/failures.dart';

import '../repositories/notification_repository.dart';

/// Parameters for [MarkNotificationReadUseCase].
class MarkNotificationReadParams extends Equatable {
  /// ID of the notification to mark as read.
  final String id;

  /// Creates [MarkNotificationReadParams].
  const MarkNotificationReadParams({required this.id});

  @override
  List<Object?> get props => [id];
}

/// Marks a single notification as read.
class MarkNotificationReadUseCase {
  /// Creates [MarkNotificationReadUseCase].
  const MarkNotificationReadUseCase(this._repository);

  final NotificationRepository _repository;

  /// Executes the use case.
  Future<Either<Failure, Unit>> call(MarkNotificationReadParams params) {
    return _repository.markAsRead(params.id);
  }
}
