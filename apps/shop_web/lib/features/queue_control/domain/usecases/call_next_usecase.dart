import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:shop_web/core/errors/shop_error_handler.dart';
import 'package:shop_web/features/queue_control/domain/entities/queue_item.dart';
import 'package:shop_web/features/queue_control/domain/repositories/queue_control_repository.dart';

/// Parameters for [CallNextUseCase].
class CallNextParams extends Equatable {
  const CallNextParams({required this.queueItemId});

  /// The ID of the queue item to call next.
  final String queueItemId;

  @override
  List<Object> get props => [queueItemId];
}

/// Calls the next customer in the queue and marks them as being served.
///
/// Returns the updated [QueueItem] on success.
class CallNextUseCase extends UseCase<QueueItem, CallNextParams> {
  CallNextUseCase(this._repository);

  final QueueControlRepository _repository;

  @override
  Future<Either<Failure, QueueItem>> call(CallNextParams params) {
    return _repository.callNext(params.queueItemId);
  }
}
