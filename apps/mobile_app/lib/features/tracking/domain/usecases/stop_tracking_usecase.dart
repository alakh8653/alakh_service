import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../repositories/tracking_repository.dart';

/// Use case that stops an active tracking session.
class StopTrackingUseCase {
  /// The repository used to stop the session.
  final TrackingRepository repository;

  /// Creates a [StopTrackingUseCase].
  const StopTrackingUseCase(this.repository);

  /// Executes the use case with [params].
  Future<Either<Failure, Unit>> call(StopTrackingParams params) =>
      repository.stopTracking(params.sessionId);
}

/// Parameters for [StopTrackingUseCase].
class StopTrackingParams extends Equatable {
  /// The session to stop.
  final String sessionId;

  /// Creates [StopTrackingParams].
  const StopTrackingParams({required this.sessionId});

  @override
  List<Object?> get props => [sessionId];
}
