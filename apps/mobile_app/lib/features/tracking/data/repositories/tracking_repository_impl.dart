import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/location.dart';
import '../../domain/entities/tracking_session.dart';
import '../../domain/repositories/tracking_repository.dart';
import '../datasources/tracking_local_datasource.dart';
import '../datasources/tracking_remote_datasource.dart';
import '../models/location_model.dart';

/// Concrete implementation of [TrackingRepository].
///
/// Coordinates between [TrackingRemoteDataSource] for live data and
/// [TrackingLocalDataSource] for offline caching.
class TrackingRepositoryImpl implements TrackingRepository {
  /// Remote datasource for server-side operations.
  final TrackingRemoteDataSource remoteDataSource;

  /// Local datasource for caching.
  final TrackingLocalDataSource localDataSource;

  /// Creates a [TrackingRepositoryImpl].
  const TrackingRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  // ---------------------------------------------------------------------------
  // Start tracking
  // ---------------------------------------------------------------------------

  @override
  Future<Either<Failure, TrackingSession>> startTracking(String jobId) async {
    try {
      final model = await remoteDataSource.startTracking(jobId);
      await localDataSource.cacheActiveSession(model);
      return Right(model);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), cause: e));
    }
  }

  // ---------------------------------------------------------------------------
  // Stop tracking
  // ---------------------------------------------------------------------------

  @override
  Future<Either<Failure, Unit>> stopTracking(String sessionId) async {
    try {
      await remoteDataSource.stopTracking(sessionId);
      await localDataSource.clearSession(sessionId);
      return const Right(unit);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), cause: e));
    }
  }

  // ---------------------------------------------------------------------------
  // Watch live location
  // ---------------------------------------------------------------------------

  @override
  Stream<Either<Failure, Location>> watchLiveLocation(
      String sessionId) async* {
    await for (final event
        in remoteDataSource.watchLiveLocation(sessionId)) {
      if (event.location != null) {
        final loc = event.location!;
        // Cache the latest location locally for offline resilience.
        await localDataSource.cacheLastLocation(sessionId, loc);
        yield Right(loc);
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Get tracking status
  // ---------------------------------------------------------------------------

  @override
  Future<Either<Failure, TrackingSession>> getTrackingStatus(
      String sessionId) async {
    try {
      final model = await remoteDataSource.getTrackingStatus(sessionId);
      await localDataSource.cacheActiveSession(model);
      return Right(model);
    } on Failure catch (f) {
      // Fall back to cache on network/server failure.
      final cached = await localDataSource.getActiveSession();
      if (cached != null && cached.id == sessionId) {
        return Right(cached);
      }
      return Left(f);
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), cause: e));
    }
  }

  // ---------------------------------------------------------------------------
  // Update location
  // ---------------------------------------------------------------------------

  @override
  Future<Either<Failure, Unit>> updateLocation(
      String sessionId, Location location) async {
    try {
      final model = LocationModel.fromEntity(location);
      await remoteDataSource.updateLocation(sessionId, model);
      await localDataSource.cacheLastLocation(sessionId, model);
      return const Right(unit);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), cause: e));
    }
  }

  // ---------------------------------------------------------------------------
  // Get ETA
  // ---------------------------------------------------------------------------

  @override
  Future<Either<Failure, Duration>> getEta(String sessionId) async {
    try {
      final seconds = await remoteDataSource.getEta(sessionId);
      return Right(Duration(seconds: seconds));
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), cause: e));
    }
  }
}
