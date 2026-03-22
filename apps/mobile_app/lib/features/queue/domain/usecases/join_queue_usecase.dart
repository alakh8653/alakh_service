import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../entities/queue_entry.dart';
import '../repositories/queue_repository.dart';

/// Use case that adds the current user to a shop's queue.
///
/// Single-responsibility: delegates directly to [QueueRepository.joinQueue].
class JoinQueueUseCase {
  /// The repository used to perform the join operation.
  final QueueRepository repository;

  /// Creates a [JoinQueueUseCase] with the given [repository].
  const JoinQueueUseCase(this.repository);

  /// Executes the use case with the provided [params].
  Future<Either<Failure, QueueEntry>> call(JoinQueueParams params) =>
      repository.joinQueue(params.shopId, serviceId: params.serviceId);
}

/// Parameters required to execute [JoinQueueUseCase].
class JoinQueueParams extends Equatable {
  /// The shop whose queue the user wants to join.
  final String shopId;

  /// Optional service identifier within the shop's queue.
  final String? serviceId;

  /// Creates [JoinQueueParams].
  const JoinQueueParams({required this.shopId, this.serviceId});

  @override
  List<Object?> get props => [shopId, serviceId];
}
