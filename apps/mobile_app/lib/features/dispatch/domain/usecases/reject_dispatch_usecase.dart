import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/dispatch_repository.dart';

/// Rejects a pending dispatch assignment.
class RejectDispatchUseCase {
  final DispatchRepository repository;

  const RejectDispatchUseCase(this.repository);

  Future<Either<Failure, Unit>> call(RejectDispatchParams params) =>
      repository.rejectDispatch(params.jobId, reason: params.reason);
}

/// Parameters required by [RejectDispatchUseCase].
class RejectDispatchParams extends Equatable {
  final String jobId;
  final String? reason;

  const RejectDispatchParams({required this.jobId, this.reason});

  @override
  List<Object?> get props => [jobId, reason];
}
