import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:shop_web/core/errors/shop_error_handler.dart';
import 'package:shop_web/features/queue_control/domain/entities/queue_item.dart';
import 'package:shop_web/features/queue_control/domain/repositories/queue_control_repository.dart';

/// Parameters for [ReorderQueueUseCase].
class ReorderQueueParams extends Equatable {
  const ReorderQueueParams({required this.orderedIds});

  /// Queue item IDs in the desired new order (index 0 = position 1).
  final List<String> orderedIds;

  @override
  List<Object> get props => [orderedIds];
}

/// Reorders queue items on the backend to match the provided [orderedIds].
///
/// Returns the full queue list with updated position values.
class ReorderQueueUseCase
    extends UseCase<List<QueueItem>, ReorderQueueParams> {
  ReorderQueueUseCase(this._repository);

  final QueueControlRepository _repository;

  @override
  Future<Either<Failure, List<QueueItem>>> call(ReorderQueueParams params) {
    return _repository.reorderQueue(params.orderedIds);
  }
}
