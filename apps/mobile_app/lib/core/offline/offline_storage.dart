/// Local storage abstraction.
///
/// Provides a simple key-value store backed by Hive (or SharedPreferences as
/// a fallback) for non-sensitive app data.
///
/// Add to pubspec.yaml:
/// ```yaml
/// dependencies:
///   hive: ^2.2.3
///   hive_flutter: ^1.1.0
///   shared_preferences: ^2.2.3
/// ```
library offline_storage;

import 'dart:convert';

import '../utils/logger.dart';

// TODO: Uncomment when packages are available:
// import 'package:hive_flutter/hive_flutter.dart';

/// Abstract interface for the offline storage layer.
abstract class OfflineStorage {
  /// Stores [value] (serialised as JSON) under [key].
  Future<void> put(String key, dynamic value);

  /// Retrieves and deserialises the value for [key], or `null`.
  Future<T?> get<T>(String key);

  /// Returns `true` if [key] exists.
  Future<bool> has(String key);

  /// Deletes the entry for [key].
  Future<void> delete(String key);

  /// Clears all entries in the store.
  Future<void> clear();

  /// Returns all keys in the store.
  Future<List<String>> keys();
}

/// In-memory [OfflineStorage] backed by a [Map].
///
/// Not persistent across app restarts — use [HiveOfflineStorage] in production.
class InMemoryOfflineStorage implements OfflineStorage {
  final _store = <String, String>{};

  @override
  Future<void> put(String key, dynamic value) async {
    _store[key] = jsonEncode(value);
  }

  @override
  Future<T?> get<T>(String key) async {
    final raw = _store[key];
    if (raw == null) return null;
    return jsonDecode(raw) as T?;
  }

  @override
  Future<bool> has(String key) async => _store.containsKey(key);

  @override
  Future<void> delete(String key) async => _store.remove(key);

  @override
  Future<void> clear() async => _store.clear();

  @override
  Future<List<String>> keys() async => _store.keys.toList();
}

/// [OfflineStorage] backed by Hive.
///
/// TODO: Implement when Hive is added to pubspec.yaml.
class HiveOfflineStorage implements OfflineStorage {
  HiveOfflineStorage();

  // TODO: late Box<String> _box;
  //
  // Future<void> init({String boxName = 'offline_store'}) async {
  //   await Hive.initFlutter();
  //   _box = await Hive.openBox<String>(boxName);
  // }

  final _log = AppLogger('HiveOfflineStorage');
  final _memory = InMemoryOfflineStorage();

  @override
  Future<void> put(String key, dynamic value) => _memory.put(key, value);

  @override
  Future<T?> get<T>(String key) => _memory.get<T>(key);

  @override
  Future<bool> has(String key) => _memory.has(key);

  @override
  Future<void> delete(String key) => _memory.delete(key);

  @override
  Future<void> clear() => _memory.clear();

  @override
  Future<List<String>> keys() => _memory.keys();
}
