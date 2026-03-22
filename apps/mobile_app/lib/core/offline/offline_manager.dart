/// Offline mode detection and queue management.
library offline_manager;

import 'dart:async';

import '../network/network_info.dart';
import '../utils/logger.dart';

// ── Pending operation model ───────────────────────────────────────────────────

/// HTTP methods for queued operations.
enum QueuedOperationMethod { get, post, put, patch, delete }

/// Represents an API operation that could not be executed while offline
/// and has been queued for later execution.
class QueuedOperation {
  QueuedOperation({
    required this.id,
    required this.method,
    required this.path,
    this.data,
    this.queryParameters,
    this.retryCount = 0,
    required this.queuedAt,
    this.tag,
  });

  /// Unique identifier for deduplication.
  final String id;

  final QueuedOperationMethod method;

  /// The API path (relative to base URL).
  final String path;

  final Map<String, dynamic>? data;
  final Map<String, dynamic>? queryParameters;

  /// Number of failed execution attempts.
  int retryCount;

  /// Timestamp when the operation was queued.
  final DateTime queuedAt;

  /// Optional tag for grouping / filtering (e.g. `'booking'`).
  final String? tag;

  @override
  String toString() =>
      'QueuedOperation(id: $id, method: ${method.name}, path: $path)';
}

// ── Offline manager ───────────────────────────────────────────────────────────

/// Manages offline state detection and a queue of pending API operations.
///
/// When the device goes offline, callers enqueue operations via [enqueue].
/// The [SyncEngine] then drains the queue when connectivity is restored.
class OfflineManager {
  OfflineManager({required NetworkInfo networkInfo})
      : _networkInfo = networkInfo {
    _init();
  }

  final NetworkInfo _networkInfo;
  final _log = AppLogger('OfflineManager');

  final _queue = <QueuedOperation>[];
  final _onlineController = StreamController<bool>.broadcast();

  bool _isOnline = true;
  StreamSubscription<bool>? _connectivitySub;

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Whether the device currently has internet connectivity.
  bool get isOnline => _isOnline;

  /// Whether the device is offline.
  bool get isOffline => !_isOnline;

  /// Stream that emits `true` when connectivity is restored and `false`
  /// when it is lost.
  Stream<bool> get onConnectivityChange => _onlineController.stream;

  /// Snapshot of all pending queued operations.
  List<QueuedOperation> get pendingOperations =>
      List.unmodifiable(_queue);

  /// Number of pending operations.
  int get pendingCount => _queue.length;

  // ── Queue management ───────────────────────────────────────────────────────

  /// Adds [operation] to the offline queue.
  void enqueue(QueuedOperation operation) {
    _queue.add(operation);
    _log.d('Queued: $operation (total: ${_queue.length})');
  }

  /// Removes the operation with [id] from the queue.
  void dequeue(String id) {
    _queue.removeWhere((op) => op.id == id);
    _log.d('Dequeued: $id');
  }

  /// Removes all operations matching [tag].
  void dequeueByTag(String tag) {
    _queue.removeWhere((op) => op.tag == tag);
  }

  /// Clears the entire queue.
  void clearQueue() {
    _queue.clear();
    _log.i('Queue cleared');
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  void _init() {
    _networkInfo.isConnected.then((connected) {
      _isOnline = connected;
      _log.i('Initial connectivity: ${_isOnline ? 'online' : 'offline'}');
    });

    _connectivitySub = _networkInfo.onConnectivityChanged.listen((connected) {
      if (connected != _isOnline) {
        _isOnline = connected;
        _onlineController.add(connected);
        _log.i('Connectivity changed: ${connected ? 'online' : 'offline'}');
      }
    });
  }

  /// Releases resources.
  Future<void> dispose() async {
    await _connectivitySub?.cancel();
    await _onlineController.close();
  }
}
