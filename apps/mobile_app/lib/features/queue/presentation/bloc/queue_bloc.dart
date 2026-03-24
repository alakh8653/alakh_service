import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/queue_entry.dart';
import '../../domain/entities/queue_status.dart';
import '../../domain/usecases/get_my_queue_position_usecase.dart';
import '../../domain/usecases/get_queue_history_usecase.dart';
import '../../domain/usecases/get_queue_status_usecase.dart';
import '../../domain/usecases/join_queue_usecase.dart';
import '../../domain/usecases/leave_queue_usecase.dart';
import '../../domain/usecases/watch_queue_updates_usecase.dart';
import 'queue_event.dart';
import 'queue_state.dart';

/// BLoC that manages all queue-related state transitions.
///
/// Consumes use cases from the domain layer and translates them into
/// [QueueState] emissions consumed by the UI.
class QueueBloc extends Bloc<QueueEvent, QueueState> {
  /// Use case for joining a queue.
  final JoinQueueUseCase joinQueueUseCase;

  /// Use case for leaving a queue.
  final LeaveQueueUseCase leaveQueueUseCase;

  /// Use case for fetching queue status.
  final GetQueueStatusUseCase getQueueStatusUseCase;

  /// Use case for fetching the user's current position.
  final GetMyQueuePositionUseCase getMyQueuePositionUseCase;

  /// Use case for subscribing to live position updates.
  final WatchQueueUpdatesUseCase watchQueueUpdatesUseCase;

  /// Use case for fetching queue history.
  final GetQueueHistoryUseCase getQueueHistoryUseCase;

  /// Active subscription to the live queue-updates stream.
  StreamSubscription<dynamic>? _positionSubscription;

  /// Creates a [QueueBloc] with the required use cases.
  QueueBloc({
    required this.joinQueueUseCase,
    required this.leaveQueueUseCase,
    required this.getQueueStatusUseCase,
    required this.getMyQueuePositionUseCase,
    required this.watchQueueUpdatesUseCase,
    required this.getQueueHistoryUseCase,
  }) : super(const QueueInitial()) {
    on<JoinQueueEvent>(_onJoinQueue);
    on<LeaveQueueEvent>(_onLeaveQueue);
    on<LoadQueueStatusEvent>(_onLoadQueueStatus);
    on<WatchPositionEvent>(_onWatchPosition);
    on<RefreshQueueEvent>(_onRefreshQueue);
    on<LoadQueueHistoryEvent>(_onLoadQueueHistory);
    on<_QueuePositionUpdateReceived>(_onPositionUpdateReceived);
    on<_QueueStreamErrorReceived>(_onStreamErrorReceived);
  }

  // ---------------------------------------------------------------------------
  // Event handlers
  // ---------------------------------------------------------------------------

  Future<void> _onJoinQueue(
    JoinQueueEvent event,
    Emitter<QueueState> emit,
  ) async {
    emit(const QueueLoading());
    final result = await joinQueueUseCase(
      JoinQueueParams(shopId: event.shopId, serviceId: event.serviceId),
    );
    result.fold(
      (failure) => emit(QueueError(message: failure.message)),
      (entry) {
        emit(QueueJoined(entry: entry));
        // Automatically start watching once joined.
        add(WatchPositionEvent(entryId: entry.id));
      },
    );
  }

  Future<void> _onLeaveQueue(
    LeaveQueueEvent event,
    Emitter<QueueState> emit,
  ) async {
    emit(const QueueLoading());
    await _cancelPositionSubscription();
    final result = await leaveQueueUseCase(
      LeaveQueueParams(entryId: event.entryId),
    );
    result.fold(
      (failure) => emit(QueueError(message: failure.message)),
      (_) => emit(const QueueInitial()),
    );
  }

  Future<void> _onLoadQueueStatus(
    LoadQueueStatusEvent event,
    Emitter<QueueState> emit,
  ) async {
    emit(const QueueLoading());
    final result = await getQueueStatusUseCase(
      GetQueueStatusParams(shopId: event.shopId),
    );
    result.fold(
      (failure) => emit(QueueError(message: failure.message)),
      (queue) => emit(QueueStatusLoaded(queue: queue)),
    );
  }

  Future<void> _onWatchPosition(
    WatchPositionEvent event,
    Emitter<QueueState> emit,
  ) async {
    await _cancelPositionSubscription();

    final stream = watchQueueUpdatesUseCase(
      WatchQueueUpdatesParams(entryId: event.entryId),
    );

    // Use emit.forEach to properly integrate the stream with the BLoC's
    // emitter lifecycle, which handles cancellation automatically.
    await emit.forEach<dynamic>(
      stream,
      onData: (data) {
        return data.fold(
          (failure) => QueueError(message: failure.message),
          (QueueEntry entry) {
            if (!entry.status.isActive) {
              return QueueCompleted(entry: entry);
            }
            return QueuePositionUpdated(entry: entry);
          },
        );
      },
      onError: (error, _) =>
          QueueError(message: error.toString()),
    );
  }

  Future<void> _onRefreshQueue(
    RefreshQueueEvent event,
    Emitter<QueueState> emit,
  ) async {
    final statusResult = await getQueueStatusUseCase(
      GetQueueStatusParams(shopId: event.shopId),
    );
    statusResult.fold(
      (failure) => emit(QueueError(message: failure.message)),
      (queue) => emit(QueueStatusLoaded(queue: queue)),
    );
  }

  Future<void> _onLoadQueueHistory(
    LoadQueueHistoryEvent event,
    Emitter<QueueState> emit,
  ) async {
    emit(const QueueLoading());
    final result = await getQueueHistoryUseCase(
      const GetQueueHistoryParams(),
    );
    result.fold(
      (failure) => emit(QueueError(message: failure.message)),
      (entries) => emit(QueueHistoryLoaded(entries: entries)),
    );
  }

  void _onPositionUpdateReceived(
    _QueuePositionUpdateReceived event,
    Emitter<QueueState> emit,
  ) {
    if (!event.entry.status.isActive) {
      emit(QueueCompleted(entry: event.entry));
    } else {
      emit(QueuePositionUpdated(entry: event.entry));
    }
  }

  void _onStreamErrorReceived(
    _QueueStreamErrorReceived event,
    Emitter<QueueState> emit,
  ) {
    emit(QueueError(message: event.message));
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Future<void> _cancelPositionSubscription() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  @override
  Future<void> close() async {
    await _cancelPositionSubscription();
    return super.close();
  }
}
