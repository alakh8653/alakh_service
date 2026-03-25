import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../entities/queue_entry.dart';
import '../repositories/queue_repository.dart';

/// Use case that retrieves the caller's current position in a queue.
///
/// Single-responsibility: delegates directly to
/// [QueueRepository.getMyQueuePosition].
class GetMyQueuePositionUseCase {
  /// The repository used to fetch the user's queue position.
  final QueueRepository repository;

  /// Creates a [GetMyQueuePositionUseCase] with the given [repository].
  const GetMyQueuePositionUseCase(this.repository);

  /// Executes the use case with the provided [params].
  Future<Either<Failure, QueueEntry>> call(GetMyQueuePositionParams params) =>
      repository.getMyQueuePosition(params.queueId);
}

/// Parameters required to execute [GetMyQueuePositionUseCase].
class GetMyQueuePositionParams extends Equatable {
  /// The queue identifier whose position is being queried.
  final String queueId;

  /// Creates [GetMyQueuePositionParams].
  const GetMyQueuePositionParams({required this.queueId});

  @override
  List<Object?> get props => [queueId];
}
