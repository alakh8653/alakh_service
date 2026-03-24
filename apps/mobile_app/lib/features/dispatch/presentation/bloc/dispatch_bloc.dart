import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/dispatch_job.dart';
import '../../domain/entities/dispatch_status.dart';
import '../../domain/usecases/accept_dispatch_usecase.dart';
import '../../domain/usecases/get_active_dispatch_usecase.dart';
import '../../domain/usecases/get_dispatch_history_usecase.dart';
import '../../domain/usecases/get_dispatch_route_usecase.dart';
import '../../domain/usecases/reject_dispatch_usecase.dart';
import '../../domain/usecases/update_dispatch_status_usecase.dart';
import '../../domain/usecases/watch_dispatch_updates_usecase.dart';
import 'dispatch_event.dart';
import 'dispatch_state.dart';

/// BLoC managing all dispatch-related state transitions.
class DispatchBloc extends Bloc<DispatchEvent, DispatchState> {
  final AcceptDispatchUseCase _acceptDispatch;
  final RejectDispatchUseCase _rejectDispatch;
  final GetActiveDispatchUseCase _getActiveDispatch;
  final UpdateDispatchStatusUseCase _updateStatus;
  final GetDispatchRouteUseCase _getRoute;
  final WatchDispatchUpdatesUseCase _watchUpdates;
  final GetDispatchHistoryUseCase _getHistory;

  StreamSubscription<dynamic>? _updatesSubscription;

  DispatchBloc({
    required AcceptDispatchUseCase acceptDispatch,
    required RejectDispatchUseCase rejectDispatch,
    required GetActiveDispatchUseCase getActiveDispatch,
    required UpdateDispatchStatusUseCase updateStatus,
    required GetDispatchRouteUseCase getRoute,
    required WatchDispatchUpdatesUseCase watchUpdates,
    required GetDispatchHistoryUseCase getHistory,
  })  : _acceptDispatch = acceptDispatch,
        _rejectDispatch = rejectDispatch,
        _getActiveDispatch = getActiveDispatch,
        _updateStatus = updateStatus,
        _getRoute = getRoute,
        _watchUpdates = watchUpdates,
        _getHistory = getHistory,
        super(const DispatchIdle()) {
    on<LoadActiveJobEvent>(_onLoadActiveJob);
    on<WatchUpdatesEvent>(_onWatchUpdates);
    on<AcceptJobEvent>(_onAcceptJob);
    on<RejectJobEvent>(_onRejectJob);
    on<UpdateStatusEvent>(_onUpdateStatus);
    on<LoadRouteEvent>(_onLoadRoute);
    on<LoadHistoryEvent>(_onLoadHistory);
    on<_JobUpdateReceivedEvent>(_onJobUpdateReceived);
  }

  Future<void> _onLoadActiveJob(
    LoadActiveJobEvent event,
    Emitter<DispatchState> emit,
  ) async {
    emit(const DispatchLoading());
    final result = await _getActiveDispatch(const NoParams());
    result.fold(
      (failure) => emit(DispatchError(message: failure.message)),
      (job) {
        if (job == null) {
          emit(const DispatchIdle());
        } else {
          emit(_stateFromJob(job));
        }
      },
    );
  }

  Future<void> _onWatchUpdates(
    WatchUpdatesEvent event,
    Emitter<DispatchState> emit,
  ) async {
    await _updatesSubscription?.cancel();

    final stream = _watchUpdates(WatchDispatchUpdatesParams(staffId: event.staffId));

    await emit.forEach<dynamic>(
      stream,
      onData: (data) => data.fold(
        (failure) => DispatchError(message: failure.message),
        (DispatchJob job) => _stateFromJob(job),
      ),
      onError: (error, _) => DispatchError(message: error.toString()),
    );
  }

  Future<void> _onAcceptJob(
    AcceptJobEvent event,
    Emitter<DispatchState> emit,
  ) async {
    emit(const DispatchLoading());
    final result = await _acceptDispatch(AcceptDispatchParams(jobId: event.jobId));
    result.fold(
      (failure) => emit(DispatchError(message: failure.message)),
      (_) => add(const LoadActiveJobEvent()),
    );
  }

  Future<void> _onRejectJob(
    RejectJobEvent event,
    Emitter<DispatchState> emit,
  ) async {
    emit(const DispatchLoading());
    final result = await _rejectDispatch(
      RejectDispatchParams(jobId: event.jobId, reason: event.reason),
    );
    result.fold(
      (failure) => emit(DispatchError(message: failure.message)),
      (_) => emit(const DispatchIdle()),
    );
  }

  Future<void> _onUpdateStatus(
    UpdateStatusEvent event,
    Emitter<DispatchState> emit,
  ) async {
    emit(const DispatchLoading());
    final result = await _updateStatus(
      UpdateDispatchStatusParams(jobId: event.jobId, status: event.status),
    );
    result.fold(
      (failure) => emit(DispatchError(message: failure.message)),
      (_) => add(const LoadActiveJobEvent()),
    );
  }

  Future<void> _onLoadRoute(
    LoadRouteEvent event,
    Emitter<DispatchState> emit,
  ) async {
    // Fetch the route and transition to EnRouteState if a job is active.
    final currentState = state;
    if (currentState is! JobAcceptedState && currentState is! EnRouteState) return;

    final job = currentState is JobAcceptedState
        ? currentState.job
        : (currentState as EnRouteState).job;

    emit(const DispatchLoading());
    final result = await _getRoute(GetDispatchRouteParams(jobId: event.jobId));
    result.fold(
      (failure) => emit(DispatchError(message: failure.message)),
      (route) => emit(EnRouteState(job: job, route: route)),
    );
  }

  Future<void> _onLoadHistory(
    LoadHistoryEvent event,
    Emitter<DispatchState> emit,
  ) async {
    emit(const DispatchLoading());
    final result = await _getHistory(GetDispatchHistoryParams(page: event.page));
    result.fold(
      (failure) => emit(DispatchError(message: failure.message)),
      (jobs) => emit(DispatchHistoryLoaded(jobs: jobs, page: event.page)),
    );
  }

  Future<void> _onJobUpdateReceived(
    _JobUpdateReceivedEvent event,
    Emitter<DispatchState> emit,
  ) async {
    if (event.jobOrFailure is DispatchJob) {
      emit(_stateFromJob(event.jobOrFailure as DispatchJob));
    }
  }

  /// Maps a [DispatchJob]'s status to the appropriate [DispatchState].
  DispatchState _stateFromJob(DispatchJob job) {
    switch (job.status) {
      case DispatchStatus.assigned:
        // When a new job is received from the stream, the presentation layer
        // converts it to a DispatchAssignment. Here we use JobAcceptedState
        // as the domain entity doesn't carry assignment-only fields.
        return JobAcceptedState(job: job);
      case DispatchStatus.accepted:
        return JobAcceptedState(job: job);
      case DispatchStatus.enRoute:
        // Route data is loaded separately via LoadRouteEvent.
        return JobAcceptedState(job: job);
      case DispatchStatus.arrived:
        return ArrivedState(job: job);
      case DispatchStatus.inProgress:
        return JobInProgressState(job: job);
      case DispatchStatus.completed:
        return JobCompletedState(job: job);
      case DispatchStatus.cancelled:
      case DispatchStatus.pending:
        return const DispatchIdle();
    }
  }

  @override
  Future<void> close() async {
    await _updatesSubscription?.cancel();
    return super.close();
  }
}
