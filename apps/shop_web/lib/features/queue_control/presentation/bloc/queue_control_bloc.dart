import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_web/core/errors/shop_error_handler.dart';
import 'package:shop_web/features/queue_control/domain/entities/queue_item.dart';
import 'package:shop_web/features/queue_control/domain/entities/queue_settings.dart';
import 'package:shop_web/features/queue_control/domain/usecases/call_next_usecase.dart';
import 'package:shop_web/features/queue_control/domain/usecases/get_live_queue_usecase.dart';
import 'package:shop_web/features/queue_control/domain/usecases/pause_queue_usecase.dart';
import 'package:shop_web/features/queue_control/domain/usecases/remove_from_queue_usecase.dart';
import 'package:shop_web/features/queue_control/domain/usecases/reorder_queue_usecase.dart';
import 'package:shop_web/features/queue_control/domain/usecases/update_queue_settings_usecase.dart';
import 'package:shop_web/features/queue_control/domain/repositories/queue_control_repository.dart';
import 'package:shop_web/features/queue_control/presentation/bloc/queue_control_event.dart';
import 'package:shop_web/features/queue_control/presentation/bloc/queue_control_state.dart';

/// BLoC managing all queue control interactions.
class QueueControlBloc
    extends Bloc<QueueControlEvent, QueueControlState> {
  QueueControlBloc({
    required GetLiveQueueUseCase getLiveQueue,
    required CallNextUseCase callNext,
    required RemoveFromQueueUseCase removeFromQueue,
    required ReorderQueueUseCase reorderQueue,
    required PauseQueueUseCase pauseQueue,
    required QueueControlRepository repository,
    required UpdateQueueSettingsUseCase updateQueueSettings,
  })  : _getLiveQueue = getLiveQueue,
        _callNext = callNext,
        _removeFromQueue = removeFromQueue,
        _reorderQueue = reorderQueue,
        _pauseQueue = pauseQueue,
        _repository = repository,
        _updateQueueSettings = updateQueueSettings,
        super(const QueueControlInitial()) {
    on<LoadQueue>(_onLoadQueue);
    on<RefreshQueue>(_onRefreshQueue);
    on<CallNextInQueue>(_onCallNext);
    on<RemoveFromQueue>(_onRemoveFromQueue);
    on<ReorderQueue>(_onReorderQueue);
    on<PauseQueue>(_onPauseQueue);
    on<ResumeQueue>(_onResumeQueue);
    on<UpdateQueueSettings>(_onUpdateSettings);
  }

  final GetLiveQueueUseCase _getLiveQueue;
  final CallNextUseCase _callNext;
  final RemoveFromQueueUseCase _removeFromQueue;
  final ReorderQueueUseCase _reorderQueue;
  final PauseQueueUseCase _pauseQueue;
  final QueueControlRepository _repository;
  final UpdateQueueSettingsUseCase _updateQueueSettings;

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  QueueControlLoaded? get _loadedState =>
      state is QueueControlLoaded ? state as QueueControlLoaded : null;

  QueueItem? _currentlyServing(List<QueueItem> items) =>
      items.where((i) => i.isServing).isNotEmpty
          ? items.firstWhere((i) => i.isServing)
          : null;

  // ---------------------------------------------------------------------------
  // Handlers
  // ---------------------------------------------------------------------------

  Future<void> _onLoadQueue(
    LoadQueue event,
    Emitter<QueueControlState> emit,
  ) async {
    emit(const QueueControlLoading());
    await _fetchAll(emit);
  }

  Future<void> _onRefreshQueue(
    RefreshQueue event,
    Emitter<QueueControlState> emit,
  ) async {
    await _fetchAll(emit);
  }

  /// Fetches both queue items and settings in parallel.
  Future<void> _fetchAll(Emitter<QueueControlState> emit) async {
    final results = await Future.wait([
      _getLiveQueue(const NoParams()),
      _repository.getQueueSettings(),
    ]);

    final queueResult = results[0] as dynamic;
    final settingsResult = results[1] as dynamic;

    List<QueueItem>? items;
    QueueSettings? settings;

    queueResult.fold(
      (f) => emit(QueueControlError((f as Failure).message)),
      (list) => items = list as List<QueueItem>,
    );

    if (items == null) return;

    settingsResult.fold(
      (f) => emit(QueueControlError((f as Failure).message)),
      (s) => settings = s as QueueSettings,
    );

    if (settings == null) return;

    emit(QueueControlLoaded(
      queueItems: items!,
      settings: settings!,
      currentlyServing: _currentlyServing(items!),
    ));
  }

  Future<void> _onCallNext(
    CallNextInQueue event,
    Emitter<QueueControlState> emit,
  ) async {
    final loaded = _loadedState;
    if (loaded == null) return;

    // Determine target item: use preferredId or first waiting item.
    final target = event.preferredId != null
        ? loaded.queueItems
            .where((i) => i.id == event.preferredId)
            .firstOrNull
        : loaded.waitingItems.isNotEmpty
            ? loaded.waitingItems.first
            : null;

    if (target == null) return;

    emit(QueueActionInProgress(
      queueItems: loaded.queueItems,
      settings: loaded.settings,
      currentlyServing: loaded.currentlyServing,
      actionDescription: 'Calling next: ${target.customerName}',
    ));

    final result = await _callNext(CallNextParams(queueItemId: target.id));
    result.fold(
      (f) => emit(QueueControlError(f.message)),
      (updatedItem) {
        final updatedList = loaded.queueItems.map((i) {
          if (i.id == updatedItem.id) return updatedItem;
          // Mark previous serving item as waiting if replaced.
          if (i.isServing && updatedItem.id != i.id) {
            return i.copyWith(status: 'waiting');
          }
          return i;
        }).toList();

        emit(QueueControlLoaded(
          queueItems: updatedList,
          settings: loaded.settings,
          currentlyServing: updatedItem,
        ));
      },
    );
  }

  Future<void> _onRemoveFromQueue(
    RemoveFromQueue event,
    Emitter<QueueControlState> emit,
  ) async {
    final loaded = _loadedState;
    if (loaded == null) return;

    // Optimistic removal.
    final optimisticList =
        loaded.queueItems.where((i) => i.id != event.id).toList();
    emit(QueueActionInProgress(
      queueItems: optimisticList,
      settings: loaded.settings,
      currentlyServing: loaded.currentlyServing?.id == event.id
          ? null
          : loaded.currentlyServing,
      actionDescription: 'Removing item ${event.id}',
    ));

    final result =
        await _removeFromQueue(RemoveFromQueueParams(id: event.id));
    result.fold(
      (f) {
        // Roll back on failure.
        emit(loaded);
        emit(QueueControlError(f.message));
      },
      (_) {
        // Re-number positions after removal.
        final reindexed = _reindexPositions(optimisticList);
        emit(QueueControlLoaded(
          queueItems: reindexed,
          settings: loaded.settings,
          currentlyServing: loaded.currentlyServing?.id == event.id
              ? null
              : loaded.currentlyServing,
        ));
      },
    );
  }

  Future<void> _onReorderQueue(
    ReorderQueue event,
    Emitter<QueueControlState> emit,
  ) async {
    final loaded = _loadedState;
    if (loaded == null) return;

    // Reorder waiting items only; serving/completed stay in place.
    final waitingItems = loaded.waitingItems.toList();
    if (event.oldIndex >= waitingItems.length ||
        event.newIndex > waitingItems.length) return;

    final item = waitingItems.removeAt(event.oldIndex);
    final insertIndex =
        event.newIndex > event.oldIndex ? event.newIndex - 1 : event.newIndex;
    waitingItems.insert(insertIndex, item);

    final reindexed = _reindexPositions(waitingItems);
    final orderedIds = reindexed.map((i) => i.id).toList();

    // Optimistic update.
    final allItems = [
      ...loaded.queueItems.where((i) => !i.isWaiting),
      ...reindexed,
    ]..sort((a, b) => a.position.compareTo(b.position));

    emit(QueueActionInProgress(
      queueItems: allItems,
      settings: loaded.settings,
      currentlyServing: loaded.currentlyServing,
      actionDescription: 'Reordering queue',
    ));

    final result =
        await _reorderQueue(ReorderQueueParams(orderedIds: orderedIds));
    result.fold(
      (f) {
        emit(loaded);
        emit(QueueControlError(f.message));
      },
      (updatedItems) => emit(QueueControlLoaded(
        queueItems: updatedItems,
        settings: loaded.settings,
        currentlyServing: _currentlyServing(updatedItems),
      )),
    );
  }

  Future<void> _onPauseQueue(
    PauseQueue event,
    Emitter<QueueControlState> emit,
  ) async {
    final loaded = _loadedState;
    if (loaded == null) return;

    emit(QueueActionInProgress(
      queueItems: loaded.queueItems,
      settings: loaded.settings,
      currentlyServing: loaded.currentlyServing,
      actionDescription: 'Pausing queue',
    ));

    final result = await _pauseQueue(PauseQueueParams(reason: event.reason));
    result.fold(
      (f) => emit(QueueControlError(f.message)),
      (settings) => emit(QueueControlLoaded(
        queueItems: loaded.queueItems,
        settings: settings,
        currentlyServing: loaded.currentlyServing,
      )),
    );
  }

  Future<void> _onResumeQueue(
    ResumeQueue event,
    Emitter<QueueControlState> emit,
  ) async {
    final loaded = _loadedState;
    if (loaded == null) return;

    emit(QueueActionInProgress(
      queueItems: loaded.queueItems,
      settings: loaded.settings,
      currentlyServing: loaded.currentlyServing,
      actionDescription: 'Resuming queue',
    ));

    final result = await _repository.resumeQueue();
    result.fold(
      (f) => emit(QueueControlError(f.message)),
      (settings) => emit(QueueControlLoaded(
        queueItems: loaded.queueItems,
        settings: settings,
        currentlyServing: loaded.currentlyServing,
      )),
    );
  }

  Future<void> _onUpdateSettings(
    UpdateQueueSettings event,
    Emitter<QueueControlState> emit,
  ) async {
    final loaded = _loadedState;
    if (loaded == null) return;

    emit(QueueActionInProgress(
      queueItems: loaded.queueItems,
      settings: loaded.settings,
      currentlyServing: loaded.currentlyServing,
      actionDescription: 'Updating settings',
    ));

    final result = await _updateQueueSettings(
      UpdateQueueSettingsParams(settings: event.settings),
    );
    result.fold(
      (f) => emit(QueueControlError(f.message)),
      (settings) => emit(QueueControlLoaded(
        queueItems: loaded.queueItems,
        settings: settings,
        currentlyServing: loaded.currentlyServing,
      )),
    );
  }

  // ---------------------------------------------------------------------------
  // Utilities
  // ---------------------------------------------------------------------------

  List<QueueItem> _reindexPositions(List<QueueItem> items) {
    return items
        .asMap()
        .entries
        .map((e) => e.value.copyWith(position: e.key + 1))
        .toList();
  }
}
