import 'package:dartz/dartz.dart';
import 'package:shop_web/core/errors/shop_error_handler.dart';
import 'package:shop_web/features/queue_control/domain/entities/queue_item.dart';
import 'package:shop_web/features/queue_control/domain/repositories/queue_control_repository.dart';

/// Fetches the current live queue from the backend.
///
/// Uses [NoParams] since no input parameters are required.
class GetLiveQueueUseCase extends UseCase<List<QueueItem>, NoParams> {
  GetLiveQueueUseCase(this._repository);

  final QueueControlRepository _repository;

  @override
  Future<Either<Failure, List<QueueItem>>> call(NoParams params) {
    return _repository.getLiveQueue();
  }
}
