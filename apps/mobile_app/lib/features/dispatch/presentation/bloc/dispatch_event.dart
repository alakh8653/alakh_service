import 'package:equatable/equatable.dart';
import '../../domain/entities/dispatch_status.dart';

/// Base class for all dispatch BLoC events.
abstract class DispatchEvent extends Equatable {
  const DispatchEvent();

  @override
  List<Object?> get props => [];
}

/// Triggers loading of the currently active dispatch job.
class LoadActiveJobEvent extends DispatchEvent {
  const LoadActiveJobEvent();
}

/// Subscribes to real-time job updates for [staffId].
class WatchUpdatesEvent extends DispatchEvent {
  final String staffId;

  const WatchUpdatesEvent({required this.staffId});

  @override
  List<Object?> get props => [staffId];
}

/// Accepts the dispatch assignment for [jobId].
class AcceptJobEvent extends DispatchEvent {
  final String jobId;

  const AcceptJobEvent({required this.jobId});

  @override
  List<Object?> get props => [jobId];
}

/// Rejects the dispatch assignment for [jobId].
class RejectJobEvent extends DispatchEvent {
  final String jobId;
  final String? reason;

  const RejectJobEvent({required this.jobId, this.reason});

  @override
  List<Object?> get props => [jobId, reason];
}

/// Updates the lifecycle status of [jobId] to [status].
class UpdateStatusEvent extends DispatchEvent {
  final String jobId;
  final DispatchStatus status;

  const UpdateStatusEvent({required this.jobId, required this.status});

  @override
  List<Object?> get props => [jobId, status];
}

/// Requests the navigable route for [jobId].
class LoadRouteEvent extends DispatchEvent {
  final String jobId;

  const LoadRouteEvent({required this.jobId});

  @override
  List<Object?> get props => [jobId];
}

/// Loads a page of dispatch history.
class LoadHistoryEvent extends DispatchEvent {
  final int page;

  const LoadHistoryEvent({this.page = 1});

  @override
  List<Object?> get props => [page];
}

/// Internal event emitted when a real-time update is received from the stream.
class _JobUpdateReceivedEvent extends DispatchEvent {
  final Object jobOrFailure;

  const _JobUpdateReceivedEvent(this.jobOrFailure);

  @override
  List<Object?> get props => [jobOrFailure];
}
