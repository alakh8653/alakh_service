import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/dispatch_repository.dart';

/// Accepts a pending dispatch assignment on behalf of the staff member.
class AcceptDispatchUseCase {
  final DispatchRepository repository;

  const AcceptDispatchUseCase(this.repository);

  /// Executes the use case with the provided [params].
  Future<Either<Failure, Unit>> call(AcceptDispatchParams params) =>
      repository.acceptDispatch(params.jobId);
}

/// Parameters required by [AcceptDispatchUseCase].
class AcceptDispatchParams extends Equatable {
  final String jobId;

  const AcceptDispatchParams({required this.jobId});

  @override
  List<Object?> get props => [jobId];
}
