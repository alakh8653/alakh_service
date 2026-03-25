/// Abstract interface for providing authentication tokens.
///
/// Implement this interface in your application layer and pass an instance
/// to [AuthInterceptor] (and optionally to your token-refresh logic).
abstract class TokenProvider {
  /// Returns the current access token, or `null` if the user is not
  /// authenticated.
  Future<String?> getAccessToken();

  /// Returns the current refresh token, or `null` if not available.
  Future<String?> getRefreshToken();

  /// Called when a 401 response is received. Implementations should attempt
  /// to obtain a new access token using the refresh token and return it, or
  /// return `null` if the refresh failed (requiring re-authentication).
  Future<String?> refreshAccessToken();

  /// Returns `true` if the current access token is expired or will expire
  /// imminently, requiring a refresh before the next API call.
  Future<bool> isAccessTokenExpired();
}
