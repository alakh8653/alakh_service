import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../entities/queue_entry.dart';
import '../repositories/queue_repository.dart';

/// Use case that retrieves the authenticated user's past queue entries.
///
/// Single-responsibility: delegates directly to
/// [QueueRepository.getQueueHistory].
class GetQueueHistoryUseCase {
  /// The repository used to fetch history.
  final QueueRepository repository;

  /// Creates a [GetQueueHistoryUseCase] with the given [repository].
  const GetQueueHistoryUseCase(this.repository);

  /// Executes the use case.
  ///
  /// No parameters are required because history is scoped to the
  /// currently authenticated user on the server side.
  Future<Either<Failure, List<QueueEntry>>> call(
    GetQueueHistoryParams params,
  ) =>
      repository.getQueueHistory();
}

/// Parameters for [GetQueueHistoryUseCase].
///
/// Currently holds no fields; reserved for future filters (e.g., date range).
class GetQueueHistoryParams extends Equatable {
  /// Creates [GetQueueHistoryParams].
  const GetQueueHistoryParams();

  @override
  List<Object?> get props => [];
}
