import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../repositories/tracking_repository.dart';

/// Use case that retrieves the estimated time of arrival for a session.
class GetEtaUseCase {
  /// The repository providing ETA data.
  final TrackingRepository repository;

  /// Creates a [GetEtaUseCase].
  const GetEtaUseCase(this.repository);

  /// Executes the use case with [params].
  Future<Either<Failure, Duration>> call(GetEtaParams params) =>
      repository.getEta(params.sessionId);
}

/// Parameters for [GetEtaUseCase].
class GetEtaParams extends Equatable {
  /// The session whose ETA is requested.
  final String sessionId;

  /// Creates [GetEtaParams].
  const GetEtaParams({required this.sessionId});

  @override
  List<Object?> get props => [sessionId];
}
