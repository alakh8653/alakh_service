import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/queue.dart';
import '../../domain/entities/queue_entry.dart';
import '../../domain/repositories/queue_repository.dart';
import '../datasources/queue_local_datasource.dart';
import '../datasources/queue_remote_datasource.dart';
import '../models/queue_entry_model.dart';
import '../models/queue_model.dart';
import '../models/queue_status_model.dart';

/// Concrete implementation of [QueueRepository].
///
/// Coordinates between the remote API ([QueueRemoteDataSource]) and local
/// cache ([QueueLocalDataSource]).  On network failures it falls back to cached
/// data where available.
class QueueRepositoryImpl implements QueueRepository {
  /// Remote datasource for live data.
  final QueueRemoteDataSource remoteDataSource;

  /// Local datasource for offline caching.
  final QueueLocalDataSource localDataSource;

  /// Creates a [QueueRepositoryImpl].
  const QueueRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  // ---------------------------------------------------------------------------
  // Join queue
  // ---------------------------------------------------------------------------

  @override
  Future<Either<Failure, QueueEntry>> joinQueue(
    String shopId, {
    String? serviceId,
  }) async {
    try {
      final model = await remoteDataSource.joinQueue(
        shopId,
        serviceId: serviceId,
      );
      await localDataSource.cacheQueueEntry(model);
      return Right(model);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), cause: e));
    }
  }

  // ---------------------------------------------------------------------------
  // Leave queue
  // ---------------------------------------------------------------------------

  @override
  Future<Either<Failure, Unit>> leaveQueue(String entryId) async {
    try {
      await remoteDataSource.leaveQueue(entryId);
      await localDataSource.clearQueueCache();
      return const Right(unit);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), cause: e));
    }
  }

  // ---------------------------------------------------------------------------
  // Queue status
  // ---------------------------------------------------------------------------

  @override
  Future<Either<Failure, Queue>> getQueueStatus(String shopId) async {
    try {
      final model = await remoteDataSource.getQueueStatus(shopId);
      await localDataSource.cacheQueueStatus(model);
      return Right(model);
    } on Failure catch (failure) {
      // Fall back to cache on network / server failure.
      final cached = await localDataSource.getCachedQueueStatus(shopId);
      if (cached != null) return Right(cached);
      return Left(failure);
    } catch (e) {
      final cached = await localDataSource.getCachedQueueStatus(shopId);
      if (cached != null) return Right(cached);
      return Left(ServerFailure(message: e.toString(), cause: e));
    }
  }

  // ---------------------------------------------------------------------------
  // My queue position
  // ---------------------------------------------------------------------------

  @override
  Future<Either<Failure, QueueEntry>> getMyQueuePosition(
    String queueId,
  ) async {
    try {
      final model = await remoteDataSource.getMyQueuePosition(queueId);
      await localDataSource.cacheQueueEntry(model);
      return Right(model);
    } on Failure catch (failure) {
      // Fall back to the last known cached entry on failure.
      final cached = await localDataSource.getCachedQueueEntry();
      if (cached != null) return Right(cached);
      return Left(failure);
    } catch (e) {
      final cached = await localDataSource.getCachedQueueEntry();
      if (cached != null) return Right(cached);
      return Left(ServerFailure(message: e.toString(), cause: e));
    }
  }

  // ---------------------------------------------------------------------------
  // Watch queue updates
  // ---------------------------------------------------------------------------

  @override
  Stream<Either<Failure, QueueEntry>> watchQueueUpdates(
    String entryId,
  ) async* {
    // Load the cached entry once so we can preserve immutable fields
    // (userId, queueId, joinedAt) that the status-update DTO does not repeat.
    final cached = await localDataSource.getCachedQueueEntry();

    yield* remoteDataSource
        .watchQueueUpdates(entryId)
        .map<Either<Failure, QueueEntry>>((QueueStatusModel statusModel) {
          // Merge the status update with fields preserved from the cached entry
          // so the domain layer receives a complete, valid QueueEntry.
          return Right(
            QueueEntryModel(
              id: statusModel.entryId,
              userId: cached?.userId ?? '',
              queueId: cached?.queueId ?? '',
              position: statusModel.position,
              // Preserve the original join timestamp; fall back to now only
              // if no cached entry is available (should not happen in practice).
              joinedAt: cached?.joinedAt ?? DateTime.now(),
              estimatedWaitTime: Duration(
                minutes: statusModel.estimatedWaitMinutes,
              ),
              status: statusModel.status,
            ),
          );
        })
        .handleError(
          (Object error) => Left<Failure, QueueEntry>(
            error is Failure
                ? error
                : ServerFailure(message: error.toString(), cause: error),
          ),
        );
  }

  // ---------------------------------------------------------------------------
  // Queue history
  // ---------------------------------------------------------------------------

  @override
  Future<Either<Failure, List<QueueEntry>>> getQueueHistory() async {
    try {
      final models = await remoteDataSource.getQueueHistory();
      return Right(models);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), cause: e));
    }
  }
}
