import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../repositories/queue_repository.dart';

/// Use case that removes the current user from their queue.
///
/// Single-responsibility: delegates directly to [QueueRepository.leaveQueue].
class LeaveQueueUseCase {
  /// The repository used to perform the leave operation.
  final QueueRepository repository;

  /// Creates a [LeaveQueueUseCase] with the given [repository].
  const LeaveQueueUseCase(this.repository);

  /// Executes the use case with the provided [params].
  Future<Either<Failure, Unit>> call(LeaveQueueParams params) =>
      repository.leaveQueue(params.entryId);
}

/// Parameters required to execute [LeaveQueueUseCase].
class LeaveQueueParams extends Equatable {
  /// The queue entry identifier to cancel/leave.
  final String entryId;

  /// Creates [LeaveQueueParams].
  const LeaveQueueParams({required this.entryId});

  @override
  List<Object?> get props => [entryId];
}
