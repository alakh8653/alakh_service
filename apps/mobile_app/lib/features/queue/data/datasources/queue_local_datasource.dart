import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/queue_entry_model.dart';
import '../models/queue_model.dart';

/// Abstract contract for local (on-device) queue data persistence.
abstract class QueueLocalDataSource {
  /// Persists [entry] to local storage so it survives app restarts.
  Future<void> cacheQueueEntry(QueueEntryModel entry);

  /// Returns the previously cached [QueueEntryModel], or `null` if absent.
  Future<QueueEntryModel?> getCachedQueueEntry();

  /// Persists [queue] status to local storage keyed by its shop ID.
  Future<void> cacheQueueStatus(QueueModel queue);

  /// Returns the previously cached [QueueModel] for [shopId], or `null`.
  Future<QueueModel?> getCachedQueueStatus(String shopId);

  /// Removes all queue-related data from local storage.
  Future<void> clearQueueCache();
}

/// Concrete [QueueLocalDataSource] implementation backed by [SharedPreferences].
class QueueLocalDataSourceImpl implements QueueLocalDataSource {
  /// The [SharedPreferences] instance used for persistence.
  final SharedPreferences prefs;

  // Storage keys
  static const String _keyQueueEntry = 'cached_queue_entry';
  static const String _keyQueueStatusPrefix = 'cached_queue_status_';

  /// Creates a [QueueLocalDataSourceImpl] with the given [prefs].
  const QueueLocalDataSourceImpl({required this.prefs});

  // ---------------------------------------------------------------------------
  // Queue entry
  // ---------------------------------------------------------------------------

  @override
  Future<void> cacheQueueEntry(QueueEntryModel entry) async {
    await prefs.setString(_keyQueueEntry, jsonEncode(entry.toJson()));
  }

  @override
  Future<QueueEntryModel?> getCachedQueueEntry() async {
    final jsonString = prefs.getString(_keyQueueEntry);
    if (jsonString == null) return null;
    try {
      return QueueEntryModel.fromJson(
        jsonDecode(jsonString) as Map<String, dynamic>,
      );
    } catch (_) {
      // Corrupt cache – treat as absent.
      await prefs.remove(_keyQueueEntry);
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Queue status
  // ---------------------------------------------------------------------------

  @override
  Future<void> cacheQueueStatus(QueueModel queue) async {
    await prefs.setString(
      '$_keyQueueStatusPrefix${queue.shopId}',
      jsonEncode(queue.toJson()),
    );
  }

  @override
  Future<QueueModel?> getCachedQueueStatus(String shopId) async {
    final jsonString = prefs.getString('$_keyQueueStatusPrefix$shopId');
    if (jsonString == null) return null;
    try {
      return QueueModel.fromJson(
        jsonDecode(jsonString) as Map<String, dynamic>,
      );
    } catch (_) {
      // Corrupt cache – treat as absent.
      await prefs.remove('$_keyQueueStatusPrefix$shopId');
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Clear cache
  // ---------------------------------------------------------------------------

  @override
  Future<void> clearQueueCache() async {
    final keysToRemove = prefs
        .getKeys()
        .where(
          (k) => k == _keyQueueEntry || k.startsWith(_keyQueueStatusPrefix),
        )
        .toList();
    for (final key in keysToRemove) {
      await prefs.remove(key);
    }
  }
}
