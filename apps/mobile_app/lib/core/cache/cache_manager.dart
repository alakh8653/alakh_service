/// In-memory and persistent cache manager.
///
/// Combines a fast in-memory LRU cache with a persistent store (e.g. Hive /
/// SharedPreferences) so data survives app restarts.
///
/// Add to pubspec.yaml:
/// ```yaml
/// dependencies:
///   hive: ^2.2.3
///   hive_flutter: ^1.1.0
/// ```
library cache_manager;

import 'dart:async';
import 'dart:convert';

import '../utils/logger.dart';
import 'cache_policy.dart';

// ── Cache entry ───────────────────────────────────────────────────────────────

/// Wraps a cached value with metadata.
class _CacheEntry<T> {
  _CacheEntry({
    required this.value,
    required this.cachedAt,
    required this.policy,
  });

  final T value;
  final DateTime cachedAt;
  final CachePolicy policy;

  bool get isExpired => policy.isExpired(cachedAt);
  bool get isStaleButUsable => policy.isStaleButUsable(cachedAt);
}

// ── Abstract interface ────────────────────────────────────────────────────────

/// Abstract interface for the cache layer.
abstract class CacheManager {
  /// Stores [value] under [key] with the given [policy].
  Future<void> put<T>(String key, T value, {CachePolicy policy = CachePolicy.medium});

  /// Retrieves the value for [key], or `null` if absent / expired.
  ///
  /// [fromJson] is required when [T] is a non-primitive type that needs
  /// deserialisation from the persistent store.
  Future<T?> get<T>(
    String key, {
    T Function(Map<String, dynamic>)? fromJson,
  });

  /// Returns `true` if [key] exists and has not expired.
  Future<bool> has(String key);

  /// Removes the entry for [key].
  Future<void> evict(String key);

  /// Clears all cached entries.
  Future<void> clear();

  /// Removes all entries whose keys start with [prefix].
  Future<void> evictByPrefix(String prefix);
}

// ── In-memory implementation ──────────────────────────────────────────────────

/// Fast in-memory [CacheManager] backed by a [Map].
///
/// Entries are lost when the app is closed. Use [PersistentCacheManager] for
/// data that must survive restarts.
class InMemoryCacheManager implements CacheManager {
  InMemoryCacheManager({this.maxEntries = 200});

  /// Maximum number of entries before the oldest is evicted (LRU).
  final int maxEntries;

  final _store = <String, _CacheEntry<dynamic>>{};
  final _log = AppLogger('InMemoryCacheManager');

  @override
  Future<void> put<T>(
    String key,
    T value, {
    CachePolicy policy = CachePolicy.medium,
  }) async {
    if (_store.length >= maxEntries) {
      _store.remove(_store.keys.first);
    }
    _store[key] = _CacheEntry<T>(
      value: value,
      cachedAt: DateTime.now().toUtc(),
      policy: policy,
    );
    _log.d('put: $key');
  }

  @override
  Future<T?> get<T>(
    String key, {
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    final entry = _store[key];
    if (entry == null) return null;
    if (entry.isExpired && !entry.isStaleButUsable) {
      _store.remove(key);
      return null;
    }
    return entry.value as T?;
  }

  @override
  Future<bool> has(String key) async {
    final entry = _store[key];
    if (entry == null) return false;
    if (entry.isExpired && !entry.isStaleButUsable) {
      _store.remove(key);
      return false;
    }
    return true;
  }

  @override
  Future<void> evict(String key) async => _store.remove(key);

  @override
  Future<void> clear() async => _store.clear();

  @override
  Future<void> evictByPrefix(String prefix) async {
    _store.removeWhere((key, _) => key.startsWith(prefix));
  }
}

// ── Persistent implementation (Hive stub) ────────────────────────────────────

/// Persistent [CacheManager] backed by Hive (or SharedPreferences as fallback).
///
/// TODO: Implement using Hive box when `hive` is added to pubspec.yaml.
class PersistentCacheManager implements CacheManager {
  PersistentCacheManager();

  final _memory = InMemoryCacheManager();
  final _log = AppLogger('PersistentCacheManager');

  // TODO: Initialise Hive box:
  // late Box<String> _box;
  //
  // Future<void> init() async {
  //   _box = await Hive.openBox<String>('app_cache');
  // }

  @override
  Future<void> put<T>(
    String key,
    T value, {
    CachePolicy policy = CachePolicy.medium,
  }) async {
    await _memory.put(key, value, policy: policy);
    // TODO: persist to Hive:
    // final payload = jsonEncode({
    //   'value': value is Map ? value : value.toString(),
    //   'cached_at': DateTime.now().toUtc().toIso8601String(),
    //   'ttl_ms': policy.ttl.inMilliseconds,
    // });
    // await _box.put(key, payload);
    _log.d('persist put: $key');
  }

  @override
  Future<T?> get<T>(
    String key, {
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    // Check memory first
    final cached = await _memory.get<T>(key, fromJson: fromJson);
    if (cached != null) return cached;

    // TODO: Fall back to Hive:
    // final raw = _box.get(key);
    // if (raw == null) return null;
    // final map = jsonDecode(raw) as Map<String, dynamic>;
    // final cachedAt = DateTime.parse(map['cached_at'] as String);
    // final ttl = Duration(milliseconds: map['ttl_ms'] as int);
    // final policy = CachePolicy(ttl: ttl);
    // if (policy.isExpired(cachedAt)) {
    //   await _box.delete(key);
    //   return null;
    // }
    // final val = fromJson != null
    //     ? fromJson(map['value'] as Map<String, dynamic>)
    //     : map['value'] as T;
    // await _memory.put(key, val, policy: policy);
    // return val;

    return null;
  }

  @override
  Future<bool> has(String key) => _memory.has(key);

  @override
  Future<void> evict(String key) async {
    await _memory.evict(key);
    // TODO: await _box.delete(key);
  }

  @override
  Future<void> clear() async {
    await _memory.clear();
    // TODO: await _box.clear();
  }

  @override
  Future<void> evictByPrefix(String prefix) async {
    await _memory.evictByPrefix(prefix);
    // TODO: for (final key in _box.keys.where((k) => k.toString().startsWith(prefix))) {
    //   await _box.delete(key);
    // }
  }
}
