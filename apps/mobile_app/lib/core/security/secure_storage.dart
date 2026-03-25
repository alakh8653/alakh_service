/// Secure key-value storage wrapper.
///
/// Add to pubspec.yaml:
/// ```yaml
/// dependencies:
///   flutter_secure_storage: ^9.2.2
/// ```
library secure_storage;

import '../utils/logger.dart';

// TODO: Uncomment when flutter_secure_storage is added:
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Abstract interface for secure key-value storage.
abstract class SecureStorage {
  /// Writes [value] for [key] securely.
  Future<void> write(String key, String value);

  /// Reads the value for [key], or `null` if absent.
  Future<String?> read(String key);

  /// Deletes the entry for [key].
  Future<void> delete(String key);

  /// Returns all key-value pairs in the secure store.
  Future<Map<String, String>> readAll();

  /// Deletes all entries.
  Future<void> deleteAll();

  /// Returns `true` if [key] exists.
  Future<bool> containsKey(String key);
}

/// [SecureStorage] backed by `flutter_secure_storage`.
///
/// - Android: Keystore-backed AES encryption.
/// - iOS:     Keychain.
/// - macOS:   Keychain.
class FlutterSecureStorageImpl implements SecureStorage {
  FlutterSecureStorageImpl();

  // TODO: Replace with real storage instance:
  // final _storage = const FlutterSecureStorage(
  //   aOptions: AndroidOptions(encryptedSharedPreferences: true),
  //   iOptions: IOSOptions(
  //     accessibility: KeychainAccessibility.first_unlock_this_device,
  //   ),
  // );

  final _log = AppLogger('SecureStorage');
  final _inMemory = <String, String>{}; // Fallback until plugin is wired up

  @override
  Future<void> write(String key, String value) async {
    // TODO: await _storage.write(key: key, value: value);
    _inMemory[key] = value;
    _log.d('write: $key');
  }

  @override
  Future<String?> read(String key) async {
    // TODO: return _storage.read(key: key);
    return _inMemory[key];
  }

  @override
  Future<void> delete(String key) async {
    // TODO: await _storage.delete(key: key);
    _inMemory.remove(key);
    _log.d('delete: $key');
  }

  @override
  Future<Map<String, String>> readAll() async {
    // TODO: return _storage.readAll();
    return Map.unmodifiable(_inMemory);
  }

  @override
  Future<void> deleteAll() async {
    // TODO: await _storage.deleteAll();
    _inMemory.clear();
    _log.i('deleteAll');
  }

  @override
  Future<bool> containsKey(String key) async {
    // TODO: return _storage.containsKey(key: key);
    return _inMemory.containsKey(key);
  }
}
