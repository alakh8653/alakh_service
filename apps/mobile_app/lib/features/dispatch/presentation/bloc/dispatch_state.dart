import 'package:equatable/equatable.dart';
import '../../domain/entities/dispatch_assignment.dart';
import '../../domain/entities/dispatch_job.dart';
import '../../domain/entities/dispatch_route.dart';

/// Base class for all dispatch BLoC states.
abstract class DispatchState extends Equatable {
  const DispatchState();

  @override
  List<Object?> get props => [];
}

/// No active job; the staff member is idle.
class DispatchIdle extends DispatchState {
  const DispatchIdle();
}

/// An async operation is in progress.
class DispatchLoading extends DispatchState {
  const DispatchLoading();
}

/// A new job assignment has arrived and is awaiting staff response.
class JobAssignedState extends DispatchState {
  final DispatchAssignment assignment;

  const JobAssignedState({required this.assignment});

  @override
  List<Object?> get props => [assignment];
}

/// The staff member has accepted the job and is preparing to travel.
class JobAcceptedState extends DispatchState {
  final DispatchJob job;

  const JobAcceptedState({required this.job});

  @override
  List<Object?> get props => [job];
}

/// The staff member is en route to the pickup location.
class EnRouteState extends DispatchState {
  final DispatchJob job;
  final DispatchRoute route;

  const EnRouteState({required this.job, required this.route});

  @override
  List<Object?> get props => [job, route];
}

/// The staff member has arrived at the pickup location.
class ArrivedState extends DispatchState {
  final DispatchJob job;

  const ArrivedState({required this.job});

  @override
  List<Object?> get props => [job];
}

/// The service is currently in progress.
class JobInProgressState extends DispatchState {
  final DispatchJob job;

  const JobInProgressState({required this.job});

  @override
  List<Object?> get props => [job];
}

/// The job has been completed successfully.
class JobCompletedState extends DispatchState {
  final DispatchJob job;

  const JobCompletedState({required this.job});

  @override
  List<Object?> get props => [job];
}

/// A paginated list of historical jobs is available.
class DispatchHistoryLoaded extends DispatchState {
  final List<DispatchJob> jobs;
  final int page;

  const DispatchHistoryLoaded({required this.jobs, required this.page});

  @override
  List<Object?> get props => [jobs, page];
}

/// An error occurred in the dispatch layer.
class DispatchError extends DispatchState {
  final String message;

  const DispatchError({required this.message});

  @override
  List<Object?> get props => [message];
}
