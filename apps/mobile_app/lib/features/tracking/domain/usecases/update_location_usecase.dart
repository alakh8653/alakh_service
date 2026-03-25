import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../entities/location.dart';
import '../repositories/tracking_repository.dart';

/// Use case that pushes the staff member's current location to the server.
class UpdateLocationUseCase {
  /// The repository used to send the location update.
  final TrackingRepository repository;

  /// Creates an [UpdateLocationUseCase].
  const UpdateLocationUseCase(this.repository);

  /// Executes the use case with [params].
  Future<Either<Failure, Unit>> call(UpdateLocationParams params) =>
      repository.updateLocation(params.sessionId, params.location);
}

/// Parameters for [UpdateLocationUseCase].
class UpdateLocationParams extends Equatable {
  /// The session to update.
  final String sessionId;

  /// The new location to publish.
  final Location location;

  /// Creates [UpdateLocationParams].
  const UpdateLocationParams({
    required this.sessionId,
    required this.location,
  });

  @override
  List<Object?> get props => [sessionId, location];
}
