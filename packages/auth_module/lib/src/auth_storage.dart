import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'auth_token.dart';

/// Abstract interface for securely persisting and retrieving [AuthToken].
///
/// Implementations must ensure tokens are stored in an encrypted, platform-
/// appropriate secure store (e.g. Keychain on iOS, Keystore on Android).
abstract class AuthStorage {
  /// Persists [token] to secure storage, overwriting any existing token.
  Future<void> saveToken(AuthToken token);

  /// Retrieves the stored [AuthToken], or `null` if none exists.
  Future<AuthToken?> getToken();

  /// Deletes all stored token data.
  Future<void> deleteToken();

  /// Returns `true` if a token is currently stored.
  Future<bool> hasToken();
}

/// [AuthStorage] implementation backed by [FlutterSecureStorage].
///
/// Each field of [AuthToken] is stored under a separate key so that partial
/// reads are detectable (all four keys must be present for a valid token).
class SecureAuthStorage implements AuthStorage {
  final FlutterSecureStorage _storage;

  static const _accessTokenKey = 'auth_access_token';
  static const _refreshTokenKey = 'auth_refresh_token';
  static const _expiresAtKey = 'auth_expires_at';
  static const _tokenTypeKey = 'auth_token_type';

  /// Creates a [SecureAuthStorage].
  ///
  /// An optional [storage] instance can be injected for testing purposes.
  SecureAuthStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<void> saveToken(AuthToken token) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: token.accessToken),
      _storage.write(key: _refreshTokenKey, value: token.refreshToken),
      _storage.write(
          key: _expiresAtKey, value: token.expiresAt.toIso8601String()),
      _storage.write(key: _tokenTypeKey, value: token.tokenType),
    ]);
  }

  @override
  Future<AuthToken?> getToken() async {
    final results = await Future.wait([
      _storage.read(key: _accessTokenKey),
      _storage.read(key: _refreshTokenKey),
      _storage.read(key: _expiresAtKey),
      _storage.read(key: _tokenTypeKey),
    ]);

    final accessToken = results[0];
    final refreshToken = results[1];
    final expiresAt = results[2];
    final tokenType = results[3];

    // Require all fields to be present; return null if any are missing.
    if (accessToken == null || refreshToken == null || expiresAt == null) {
      return null;
    }

    return AuthToken(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: DateTime.parse(expiresAt),
      tokenType: tokenType ?? 'Bearer',
    );
  }

  @override
  Future<void> deleteToken() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
      _storage.delete(key: _expiresAtKey),
      _storage.delete(key: _tokenTypeKey),
    ]);
  }

  @override
  Future<bool> hasToken() async {
    final value = await _storage.read(key: _accessTokenKey);
    return value != null;
  }
}
