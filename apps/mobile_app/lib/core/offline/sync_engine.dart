/// Background sync engine that processes queued operations when online.
library sync_engine;

import 'dart:async';
import 'dart:math' as math;

import '../network/api_client.dart';
import '../network/api_response.dart';
import '../utils/logger.dart';
import 'offline_manager.dart';

/// Status of the [SyncEngine].
enum SyncEngineStatus {
  idle,
  syncing,
  paused,
  error,
}

/// Callback invoked after each operation succeeds or fails during a sync cycle.
typedef SyncOperationCallback = void Function(
  QueuedOperation operation,
  bool success,
  Object? error,
);

/// Drains the [OfflineManager] queue by replaying operations in order
/// when connectivity is restored.
///
/// Usage:
/// ```dart
/// final syncEngine = SyncEngine(
///   offlineManager: sl(),
///   apiClient: sl(),
/// );
/// syncEngine.start();
/// ```
class SyncEngine {
  SyncEngine({
    required OfflineManager offlineManager,
    required ApiClient apiClient,
    this.maxRetries = 3,
    this.onOperationComplete,
  })  : _offline = offlineManager,
        _api = apiClient;

  final OfflineManager _offline;
  final ApiClient _api;

  /// Maximum retry attempts per operation before it is discarded.
  final int maxRetries;

  /// Optional callback called after each operation attempt.
  final SyncOperationCallback? onOperationComplete;

  final _log = AppLogger('SyncEngine');

  SyncEngineStatus _status = SyncEngineStatus.idle;
  StreamSubscription<bool>? _connectivitySub;

  // ── Public API ─────────────────────────────────────────────────────────────

  SyncEngineStatus get status => _status;

  /// Starts the sync engine.
  ///
  /// It will listen for connectivity changes and automatically sync when
  /// the device comes back online.
  void start() {
    _connectivitySub = _offline.onConnectivityChange.listen((isOnline) {
      if (isOnline && _offline.pendingCount > 0) {
        _log.i('Connectivity restored – starting sync');
        _runSyncCycle();
      }
    });
    _log.i('SyncEngine started');
  }

  /// Stops the sync engine and cancels connectivity monitoring.
  Future<void> stop() async {
    await _connectivitySub?.cancel();
    _status = SyncEngineStatus.idle;
    _log.i('SyncEngine stopped');
  }

  /// Triggers a manual sync cycle immediately.
  Future<void> syncNow() async {
    if (_offline.isOffline) {
      _log.w('syncNow called while offline – aborting');
      return;
    }
    await _runSyncCycle();
  }

  // ── Private ───────────────────────────────────────────────────────────────

  Future<void> _runSyncCycle() async {
    if (_status == SyncEngineStatus.syncing) return;
    if (_offline.pendingCount == 0) return;

    _status = SyncEngineStatus.syncing;
    _log.i('Sync cycle starting – ${_offline.pendingCount} pending operation(s)');

    final pending = List<QueuedOperation>.from(_offline.pendingOperations);

    for (final operation in pending) {
      if (_offline.isOffline) {
        _log.w('Device went offline during sync – pausing');
        _status = SyncEngineStatus.paused;
        return;
      }

      final success = await _executeOperation(operation);
      if (success) {
        _offline.dequeue(operation.id);
        onOperationComplete?.call(operation, true, null);
      } else {
        operation.retryCount++;
        if (operation.retryCount >= maxRetries) {
          _log.e(
            'Operation ${operation.id} exceeded max retries – discarding',
          );
          _offline.dequeue(operation.id);
          onOperationComplete?.call(
            operation,
            false,
            'Max retries exceeded',
          );
        }
      }
    }

    _status = SyncEngineStatus.idle;
    _log.i(
      'Sync cycle complete – ${_offline.pendingCount} remaining',
    );
  }

  Future<bool> _executeOperation(QueuedOperation operation) async {
    try {
      final ApiResponse<dynamic> response;

      switch (operation.method) {
        case QueuedOperationMethod.post:
          response = await _api.post(operation.path, data: operation.data);
        case QueuedOperationMethod.put:
          response = await _api.put(operation.path, data: operation.data);
        case QueuedOperationMethod.patch:
          response = await _api.patch(operation.path, data: operation.data);
        case QueuedOperationMethod.delete:
          response = await _api.delete(operation.path, data: operation.data);
        case QueuedOperationMethod.get:
          response = await _api.get(
            operation.path,
            queryParameters: operation.queryParameters,
          );
      }

      if (response.isSuccess) {
        _log.d('Synced: ${operation.id}');
        return true;
      }

      _log.w(
        'Operation ${operation.id} returned error: '
        '${response.errorMessageOrNull}',
      );
      return false;
    } catch (e) {
      _log.e('Operation ${operation.id} threw: $e');
      onOperationComplete?.call(operation, false, e);
      return false;
    }
  }

  Future<void> dispose() => stop();
}
