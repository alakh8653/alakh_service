import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../entities/dispatch_route.dart';
import '../repositories/dispatch_repository.dart';

/// Fetches the navigable route for a given dispatch job.
class GetDispatchRouteUseCase {
  final DispatchRepository repository;

  const GetDispatchRouteUseCase(this.repository);

  Future<Either<Failure, DispatchRoute>> call(GetDispatchRouteParams params) =>
      repository.getDispatchRoute(params.jobId);
}

/// Parameters required by [GetDispatchRouteUseCase].
class GetDispatchRouteParams extends Equatable {
  final String jobId;

  const GetDispatchRouteParams({required this.jobId});

  @override
  List<Object?> get props => [jobId];
}
