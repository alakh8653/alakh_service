import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:shop_web/core/errors/shop_error_handler.dart';
import 'package:shop_web/features/queue_control/domain/repositories/queue_control_repository.dart';

/// Parameters for [RemoveFromQueueUseCase].
class RemoveFromQueueParams extends Equatable {
  const RemoveFromQueueParams({required this.id});

  /// The ID of the queue item to remove.
  final String id;

  @override
  List<Object> get props => [id];
}

/// Removes a customer entry from the active queue.
///
/// This is a permanent operation; the item will be given a cancelled status.
class RemoveFromQueueUseCase extends UseCase<void, RemoveFromQueueParams> {
  RemoveFromQueueUseCase(this._repository);

  final QueueControlRepository _repository;

  @override
  Future<Either<Failure, void>> call(RemoveFromQueueParams params) {
    return _repository.removeFromQueue(params.id);
  }
}
