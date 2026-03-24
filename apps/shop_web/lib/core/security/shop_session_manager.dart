/// Secure token and session storage for the Shop Web application.
library;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Manages the shop operator's session tokens and identifiers using
/// [FlutterSecureStorage] so that sensitive data is stored in the platform
/// secure enclave (Keychain on iOS/macOS, Keystore on Android, encrypted file
/// on Web/Windows).
class ShopSessionManager {
  /// Creates a [ShopSessionManager] with an optional custom [storage].
  ///
  /// Inject a mock storage in tests to avoid platform-channel calls.
  ShopSessionManager({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
            );

  final FlutterSecureStorage _storage;

  // Storage keys – kept private to prevent accidental misuse.
  static const _keyAccessToken = '_shop_access_token';
  static const _keyRefreshToken = '_shop_refresh_token';
  static const _keyShopId = '_shop_id';

  // -------------------------------------------------------------------------
  // Token management
  // -------------------------------------------------------------------------

  /// Persists [accessToken] and [refreshToken] in secure storage.
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: _keyAccessToken, value: accessToken),
      _storage.write(key: _keyRefreshToken, value: refreshToken),
    ]);
  }

  /// Returns the stored access token, or `null` if none is saved.
  Future<String?> getAccessToken() => _storage.read(key: _keyAccessToken);

  /// Returns the stored refresh token, or `null` if none is saved.
  Future<String?> getRefreshToken() => _storage.read(key: _keyRefreshToken);

  // -------------------------------------------------------------------------
  // Shop identity
  // -------------------------------------------------------------------------

  /// Persists the [shopId] associated with the current session.
  Future<void> saveShopId(String shopId) =>
      _storage.write(key: _keyShopId, value: shopId);

  /// Returns the stored shop id, or `null` if none is saved.
  Future<String?> getShopId() => _storage.read(key: _keyShopId);

  // -------------------------------------------------------------------------
  // Session lifecycle
  // -------------------------------------------------------------------------

  /// Returns `true` if an access token is currently stored.
  ///
  /// This is a lightweight check suitable for route guards; for a full
  /// validity check the token should be validated against the server.
  Future<bool> get isAuthenticated async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Deletes all session data from secure storage.
  Future<void> clearSession() async {
    await Future.wait([
      _storage.delete(key: _keyAccessToken),
      _storage.delete(key: _keyRefreshToken),
      _storage.delete(key: _keyShopId),
    ]);
  }
}
