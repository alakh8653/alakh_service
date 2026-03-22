import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/dispatch_job.dart';
import '../../domain/entities/dispatch_route.dart';
import '../../domain/entities/dispatch_status.dart';
import '../../domain/repositories/dispatch_repository.dart';
import '../datasources/dispatch_local_datasource.dart';
import '../datasources/dispatch_remote_datasource.dart';
import '../models/dispatch_job_model.dart';

/// Concrete implementation of [DispatchRepository].
///
/// Orchestrates between [DispatchRemoteDataSource] and
/// [DispatchLocalDataSource], applying a cache-then-remote strategy.
class DispatchRepositoryImpl implements DispatchRepository {
  final DispatchRemoteDataSource _remote;
  final DispatchLocalDataSource _local;

  const DispatchRepositoryImpl({
    required DispatchRemoteDataSource remote,
    required DispatchLocalDataSource local,
  })  : _remote = remote,
        _local = local;

  @override
  Future<Either<Failure, Unit>> acceptDispatch(String jobId) async {
    try {
      await _remote.acceptDispatch(jobId);
      return const Right(unit);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error accepting job.', cause: e));
    }
  }

  @override
  Future<Either<Failure, Unit>> rejectDispatch(String jobId, {String? reason}) async {
    try {
      await _remote.rejectDispatch(jobId, reason: reason);
      await _local.clearActiveJob();
      return const Right(unit);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error rejecting job.', cause: e));
    }
  }

  @override
  Future<Either<Failure, DispatchJob?>> getActiveDispatch() async {
    try {
      final remoteJob = await _remote.getActiveDispatch();
      if (remoteJob != null) {
        await _local.cacheActiveJob(remoteJob);
        return Right(remoteJob);
      }
      await _local.clearActiveJob();
      return const Right(null);
    } on Failure catch (f) {
      // Fall back to cache on network failure.
      if (f is NetworkFailure || (f is ServerFailure && (f.statusCode ?? 0) >= 500)) {
        try {
          final cached = await _local.getCachedActiveJob();
          return Right(cached);
        } on Failure catch (cacheFailure) {
          return Left(cacheFailure);
        }
      }
      return Left(f);
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error loading active job.', cause: e));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateDispatchStatus(
    String jobId,
    DispatchStatus status,
  ) async {
    try {
      await _remote.updateDispatchStatus(jobId, status);
      // Update cached job status if present.
      final DispatchJobModel? cached = await _local.getCachedActiveJob();
      if (cached != null && cached.id == jobId) {
        // Dart promotes `cached` to non-nullable inside this block.
        await _local.cacheActiveJob(cached.copyWith(status: status));
      }
      return const Right(unit);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error updating status.', cause: e));
    }
  }

  @override
  Future<Either<Failure, DispatchRoute>> getDispatchRoute(String jobId) async {
    try {
      final route = await _remote.getDispatchRoute(jobId);
      return Right(route);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error loading route.', cause: e));
    }
  }

  @override
  Stream<Either<Failure, DispatchJob>> watchDispatchUpdates(String staffId) {
    return _remote.watchDispatchUpdates(staffId).map<Either<Failure, DispatchJob>>(
      (model) {
        _local.cacheActiveJob(model);
        return Right(model);
      },
    ).handleError((Object error) {
      if (error is Failure) return Left(error);
      return Left(ServerFailure(message: error.toString(), cause: error));
    });
  }

  @override
  Future<Either<Failure, List<DispatchJob>>> getDispatchHistory({int page = 1}) async {
    try {
      final jobs = await _remote.getDispatchHistory(page: page);
      return Right(jobs);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error loading history.', cause: e));
    }
  }
}
