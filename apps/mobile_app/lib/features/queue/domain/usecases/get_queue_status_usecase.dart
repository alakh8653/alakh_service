import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../entities/queue.dart';
import '../repositories/queue_repository.dart';

/// Use case that retrieves the current status of a shop's queue.
///
/// Single-responsibility: delegates directly to [QueueRepository.getQueueStatus].
class GetQueueStatusUseCase {
  /// The repository used to fetch queue status.
  final QueueRepository repository;

  /// Creates a [GetQueueStatusUseCase] with the given [repository].
  const GetQueueStatusUseCase(this.repository);

  /// Executes the use case with the provided [params].
  Future<Either<Failure, Queue>> call(GetQueueStatusParams params) =>
      repository.getQueueStatus(params.shopId);
}

/// Parameters required to execute [GetQueueStatusUseCase].
class GetQueueStatusParams extends Equatable {
  /// The shop identifier whose queue status is being queried.
  final String shopId;

  /// Creates [GetQueueStatusParams].
  const GetQueueStatusParams({required this.shopId});

  @override
  List<Object?> get props => [shopId];
}
