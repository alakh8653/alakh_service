import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../entities/location.dart';
import '../repositories/tracking_repository.dart';

/// Use case that returns a stream of live location updates for a session.
class WatchLiveLocationUseCase {
  /// The repository providing the location stream.
  final TrackingRepository repository;

  /// Creates a [WatchLiveLocationUseCase].
  const WatchLiveLocationUseCase(this.repository);

  /// Returns a live location stream for [params.sessionId].
  Stream<Either<Failure, Location>> call(WatchLiveLocationParams params) =>
      repository.watchLiveLocation(params.sessionId);
}

/// Parameters for [WatchLiveLocationUseCase].
class WatchLiveLocationParams extends Equatable {
  /// The session to watch.
  final String sessionId;

  /// Creates [WatchLiveLocationParams].
  const WatchLiveLocationParams({required this.sessionId});

  @override
  List<Object?> get props => [sessionId];
}
