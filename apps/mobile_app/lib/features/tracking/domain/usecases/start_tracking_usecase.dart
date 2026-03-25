import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../entities/tracking_session.dart';
import '../repositories/tracking_repository.dart';

/// Use case that starts a new tracking session for a job.
class StartTrackingUseCase {
  /// The repository used to start the session.
  final TrackingRepository repository;

  /// Creates a [StartTrackingUseCase].
  const StartTrackingUseCase(this.repository);

  /// Executes the use case with [params].
  Future<Either<Failure, TrackingSession>> call(StartTrackingParams params) =>
      repository.startTracking(params.jobId);
}

/// Parameters for [StartTrackingUseCase].
class StartTrackingParams extends Equatable {
  /// The job to start tracking for.
  final String jobId;

  /// Creates [StartTrackingParams].
  const StartTrackingParams({required this.jobId});

  @override
  List<Object?> get props => [jobId];
}
