/// Abstract interface for persisting and retrieving authentication tokens.
///
/// Implement this interface using a secure storage backend (e.g.
/// `flutter_secure_storage`) and wire it into your [TokenProvider]
/// implementation.
abstract class TokenStorage {
  /// Persists the given [token] as the access token.
  Future<void> saveAccessToken(String token);

  /// Persists the given [token] as the refresh token.
  Future<void> saveRefreshToken(String token);

  /// Retrieves the stored access token, or `null` if none has been saved.
  Future<String?> getAccessToken();

  /// Retrieves the stored refresh token, or `null` if none has been saved.
  Future<String?> getRefreshToken();

  /// Removes all stored tokens (e.g. on sign-out).
  Future<void> clearTokens();
}
