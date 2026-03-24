import 'package:dartz/dartz.dart';
import 'package:shop_web/core/errors/shop_error_handler.dart';
import 'package:shop_web/core/errors/shop_exceptions.dart';
import 'package:shop_web/features/queue_control/data/datasources/queue_control_remote_datasource.dart';
import 'package:shop_web/features/queue_control/data/models/queue_settings_model.dart';
import 'package:shop_web/features/queue_control/domain/entities/queue_item.dart';
import 'package:shop_web/features/queue_control/domain/entities/queue_settings.dart';
import 'package:shop_web/features/queue_control/domain/repositories/queue_control_repository.dart';

/// Concrete implementation of [QueueControlRepository].
///
/// Delegates API calls to [QueueControlRemoteDataSource] and maps
/// exceptions to typed [Failure] variants.
class QueueControlRepositoryImpl implements QueueControlRepository {
  QueueControlRepositoryImpl(this._remoteDataSource);

  final QueueControlRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, List<QueueItem>>> getLiveQueue() async {
    try {
      final models = await _remoteDataSource.getLiveQueue();
      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, QueueItem>> callNext(String queueItemId) async {
    try {
      final model = await _remoteDataSource.callNext(queueItemId);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromQueue(String id) async {
    try {
      await _remoteDataSource.removeFromQueue(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<QueueItem>>> reorderQueue(
    List<String> orderedIds,
  ) async {
    try {
      final models = await _remoteDataSource.reorderQueue(orderedIds);
      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, QueueSettings>> pauseQueue(String reason) async {
    try {
      final model = await _remoteDataSource.pauseQueue(reason);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, QueueSettings>> resumeQueue() async {
    try {
      final model = await _remoteDataSource.resumeQueue();
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, QueueSettings>> getQueueSettings() async {
    try {
      final model = await _remoteDataSource.getQueueSettings();
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, QueueSettings>> updateQueueSettings(
    QueueSettings settings,
  ) async {
    try {
      final model = await _remoteDataSource.updateQueueSettings(
        QueueSettingsModel.fromEntity(settings),
      );
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }
}
