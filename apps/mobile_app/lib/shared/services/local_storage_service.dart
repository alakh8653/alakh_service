/// SharedPreferences wrapper for simple key-value storage.
library;

// TODO: Add `shared_preferences` package to pubspec.yaml.
// import 'package:shared_preferences/shared_preferences.dart';

/// A lightweight wrapper around [SharedPreferences] that provides a typed API
/// and avoids direct dependency on the plugin throughout the codebase.
///
/// ### Usage:
/// ```dart
/// final storage = LocalStorageService.instance;
/// await storage.setString('key', 'value');
/// final value = storage.getString('key');
/// ```
abstract interface class ILocalStorageService {
  Future<bool> setString(String key, String value);
  String? getString(String key);
  Future<bool> setInt(String key, int value);
  int? getInt(String key);
  Future<bool> setDouble(String key, double value);
  double? getDouble(String key);
  Future<bool> setBool(String key, bool value);
  bool? getBool(String key);
  Future<bool> setStringList(String key, List<String> values);
  List<String>? getStringList(String key);
  Future<bool> remove(String key);
  Future<bool> clear();
  bool containsKey(String key);
}

/// Concrete implementation of [ILocalStorageService].
class LocalStorageService implements ILocalStorageService {
  LocalStorageService._();

  static final LocalStorageService _instance = LocalStorageService._();

  /// Singleton instance — call [init] before using.
  static LocalStorageService get instance => _instance;

  // TODO: Replace the in-memory map with a real SharedPreferences instance.
  // SharedPreferences? _prefs;
  final Map<String, Object> _memoryStore = {};

  /// Initialises the underlying [SharedPreferences] instance.
  ///
  /// Must be called once before the service is used (typically in
  /// `main.dart` / `bootstrap.dart`).
  Future<void> init() async {
    // TODO: _prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<bool> setString(String key, String value) async {
    _memoryStore[key] = value;
    return true;
    // return _prefs!.setString(key, value);
  }

  @override
  String? getString(String key) => _memoryStore[key] as String?;

  @override
  Future<bool> setInt(String key, int value) async {
    _memoryStore[key] = value;
    return true;
  }

  @override
  int? getInt(String key) => _memoryStore[key] as int?;

  @override
  Future<bool> setDouble(String key, double value) async {
    _memoryStore[key] = value;
    return true;
  }

  @override
  double? getDouble(String key) => _memoryStore[key] as double?;

  @override
  Future<bool> setBool(String key, bool value) async {
    _memoryStore[key] = value;
    return true;
  }

  @override
  bool? getBool(String key) => _memoryStore[key] as bool?;

  @override
  Future<bool> setStringList(String key, List<String> values) async {
    _memoryStore[key] = values;
    return true;
  }

  @override
  List<String>? getStringList(String key) =>
      _memoryStore[key] as List<String>?;

  @override
  Future<bool> remove(String key) async {
    _memoryStore.remove(key);
    return true;
  }

  @override
  Future<bool> clear() async {
    _memoryStore.clear();
    return true;
  }

  @override
  bool containsKey(String key) => _memoryStore.containsKey(key);
}
