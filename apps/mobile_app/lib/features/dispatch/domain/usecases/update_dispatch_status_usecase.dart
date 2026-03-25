import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../entities/dispatch_status.dart';
import '../repositories/dispatch_repository.dart';

/// Transitions a dispatch job to a new lifecycle status.
class UpdateDispatchStatusUseCase {
  final DispatchRepository repository;

  const UpdateDispatchStatusUseCase(this.repository);

  Future<Either<Failure, Unit>> call(UpdateDispatchStatusParams params) =>
      repository.updateDispatchStatus(params.jobId, params.status);
}

/// Parameters required by [UpdateDispatchStatusUseCase].
class UpdateDispatchStatusParams extends Equatable {
  final String jobId;
  final DispatchStatus status;

  const UpdateDispatchStatusParams({required this.jobId, required this.status});

  @override
  List<Object?> get props => [jobId, status];
}
