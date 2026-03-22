import 'dart:convert';
import '../models/models.dart';

/// Abstract interface for local authentication data source.
abstract class AuthLocalDataSource {
  /// Persists the authentication token securely.
  Future<void> saveToken(AuthTokenModel token);

  /// Retrieves the stored authentication token.
  Future<AuthTokenModel?> getToken();

  /// Removes the stored authentication token.
  Future<void> clearToken();

  /// Persists the user profile locally.
  Future<void> saveUser(UserModel user);

  /// Retrieves the locally cached user profile.
  Future<UserModel?> getUser();

  /// Removes the locally cached user profile.
  Future<void> clearUser();

  /// Clears all locally stored authentication data.
  Future<void> clearAll();
}

/// Concrete implementation of [AuthLocalDataSource] using flutter_secure_storage.
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  // TODO: Inject FlutterSecureStorage via constructor for testability.
  // final FlutterSecureStorage _storage;
  // const AuthLocalDataSourceImpl({required FlutterSecureStorage storage}) : _storage = storage;

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';

  @override
  Future<void> saveToken(AuthTokenModel token) async {
    // TODO: Replace with: await _storage.write(key: _tokenKey, value: jsonEncode(token.toJson()));
    final tokenJson = jsonEncode(token.toJson());
    // Placeholder — in production use flutter_secure_storage write.
    _inMemoryStore[_tokenKey] = tokenJson;
  }

  @override
  Future<AuthTokenModel?> getToken() async {
    // TODO: Replace with: final value = await _storage.read(key: _tokenKey);
    final value = _inMemoryStore[_tokenKey];
    if (value == null) return null;
    return AuthTokenModel.fromJson(jsonDecode(value) as Map<String, dynamic>);
  }

  @override
  Future<void> clearToken() async {
    // TODO: Replace with: await _storage.delete(key: _tokenKey);
    _inMemoryStore.remove(_tokenKey);
  }

  @override
  Future<void> saveUser(UserModel user) async {
    // TODO: Replace with: await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
    _inMemoryStore[_userKey] = jsonEncode(user.toJson());
  }

  @override
  Future<UserModel?> getUser() async {
    // TODO: Replace with: final value = await _storage.read(key: _userKey);
    final value = _inMemoryStore[_userKey];
    if (value == null) return null;
    return UserModel.fromJson(jsonDecode(value) as Map<String, dynamic>);
  }

  @override
  Future<void> clearUser() async {
    // TODO: Replace with: await _storage.delete(key: _userKey);
    _inMemoryStore.remove(_userKey);
  }

  @override
  Future<void> clearAll() async {
    // TODO: Replace with: await _storage.deleteAll();
    _inMemoryStore.clear();
  }

  // Temporary in-memory store until flutter_secure_storage is wired up.
  static final Map<String, String> _inMemoryStore = {};
}
