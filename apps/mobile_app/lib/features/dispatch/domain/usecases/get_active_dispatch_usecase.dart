import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../entities/dispatch_job.dart';
import '../repositories/dispatch_repository.dart';

/// Retrieves the currently active dispatch job for the logged-in staff member.
class GetActiveDispatchUseCase {
  final DispatchRepository repository;

  const GetActiveDispatchUseCase(this.repository);

  Future<Either<Failure, DispatchJob?>> call(NoParams params) =>
      repository.getActiveDispatch();
}

/// Sentinel params class for use cases that require no arguments.
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
