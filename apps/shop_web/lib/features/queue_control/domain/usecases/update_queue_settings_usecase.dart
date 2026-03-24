import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:shop_web/core/errors/shop_error_handler.dart';
import 'package:shop_web/features/queue_control/domain/entities/queue_settings.dart';
import 'package:shop_web/features/queue_control/domain/repositories/queue_control_repository.dart';

/// Parameters for [UpdateQueueSettingsUseCase].
class UpdateQueueSettingsParams extends Equatable {
  const UpdateQueueSettingsParams({required this.settings});

  /// The new settings to persist.
  final QueueSettings settings;

  @override
  List<Object> get props => [settings];
}

/// Persists updated [QueueSettings] to the backend.
///
/// Returns the saved [QueueSettings] as confirmed by the server.
class UpdateQueueSettingsUseCase
    extends UseCase<QueueSettings, UpdateQueueSettingsParams> {
  UpdateQueueSettingsUseCase(this._repository);

  final QueueControlRepository _repository;

  @override
  Future<Either<Failure, QueueSettings>> call(
    UpdateQueueSettingsParams params,
  ) {
    return _repository.updateQueueSettings(params.settings);
  }
}
