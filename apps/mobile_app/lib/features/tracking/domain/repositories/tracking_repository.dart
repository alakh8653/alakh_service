import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/location.dart';
import '../entities/tracking_session.dart';

/// Abstract contract for all tracking data operations.
abstract class TrackingRepository {
  /// Starts a new tracking session for [jobId].
  Future<Either<Failure, TrackingSession>> startTracking(String jobId);

  /// Stops the session identified by [sessionId].
  Future<Either<Failure, Unit>> stopTracking(String sessionId);

  /// Returns a stream of real-time location updates for [sessionId].
  Stream<Either<Failure, Location>> watchLiveLocation(String sessionId);

  /// Fetches the current state of the session [sessionId].
  Future<Either<Failure, TrackingSession>> getTrackingStatus(String sessionId);

  /// Pushes a new [location] update for [sessionId] (staff-side).
  Future<Either<Failure, Unit>> updateLocation(
      String sessionId, Location location);

  /// Calculates and returns the ETA for [sessionId].
  Future<Either<Failure, Duration>> getEta(String sessionId);
}
