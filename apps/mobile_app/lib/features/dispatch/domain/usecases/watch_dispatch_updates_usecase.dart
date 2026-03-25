import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../entities/dispatch_job.dart';
import '../repositories/dispatch_repository.dart';

/// Returns a real-time stream of dispatch job updates for a staff member.
class WatchDispatchUpdatesUseCase {
  final DispatchRepository repository;

  const WatchDispatchUpdatesUseCase(this.repository);

  Stream<Either<Failure, DispatchJob>> call(WatchDispatchUpdatesParams params) =>
      repository.watchDispatchUpdates(params.staffId);
}

/// Parameters required by [WatchDispatchUpdatesUseCase].
class WatchDispatchUpdatesParams extends Equatable {
  final String staffId;

  const WatchDispatchUpdatesParams({required this.staffId});

  @override
  List<Object?> get props => [staffId];
}
