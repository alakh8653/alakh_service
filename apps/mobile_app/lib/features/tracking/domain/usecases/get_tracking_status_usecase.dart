import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../entities/tracking_session.dart';
import '../repositories/tracking_repository.dart';

/// Use case that fetches the current tracking session status.
class GetTrackingStatusUseCase {
  /// The repository providing the session data.
  final TrackingRepository repository;

  /// Creates a [GetTrackingStatusUseCase].
  const GetTrackingStatusUseCase(this.repository);

  /// Executes the use case with [params].
  Future<Either<Failure, TrackingSession>> call(
          GetTrackingStatusParams params) =>
      repository.getTrackingStatus(params.sessionId);
}

/// Parameters for [GetTrackingStatusUseCase].
class GetTrackingStatusParams extends Equatable {
  /// The session to fetch.
  final String sessionId;

  /// Creates [GetTrackingStatusParams].
  const GetTrackingStatusParams({required this.sessionId});

  @override
  List<Object?> get props => [sessionId];
}
