import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:shop_web/core/errors/shop_error_handler.dart';
import 'package:shop_web/features/queue_control/domain/entities/queue_settings.dart';
import 'package:shop_web/features/queue_control/domain/repositories/queue_control_repository.dart';

/// Parameters for [PauseQueueUseCase].
class PauseQueueParams extends Equatable {
  const PauseQueueParams({required this.reason});

  /// Human-readable explanation for why the queue is being paused.
  final String reason;

  @override
  List<Object> get props => [reason];
}

/// Pauses the queue and prevents new customers from joining or being called.
///
/// Returns updated [QueueSettings] reflecting the paused state.
class PauseQueueUseCase extends UseCase<QueueSettings, PauseQueueParams> {
  PauseQueueUseCase(this._repository);

  final QueueControlRepository _repository;

  @override
  Future<Either<Failure, QueueSettings>> call(PauseQueueParams params) {
    return _repository.pauseQueue(params.reason);
  }
}
