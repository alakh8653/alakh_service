import 'package:api_client/api_client.dart';

import 'auth_state.dart';
import 'token_manager.dart';

/// Handles login, logout, registration, and token refresh flows.
class AuthService {
  AuthService({
    required ApiClient apiClient,
    required TokenManager tokenManager,
  })  : _apiClient = apiClient,
        _tokenManager = tokenManager;

  final ApiClient _apiClient;
  final TokenManager _tokenManager;

  /// Returns the current auth state based on stored tokens.
  Future<AuthState> getAuthState() async {
    final accessToken = await _tokenManager.getAccessToken();
    if (accessToken == null) return const AuthState.unauthenticated();
    if (_tokenManager.isTokenExpired(accessToken)) {
      final refreshed = await refreshToken();
      return refreshed ? const AuthState.authenticated() : const AuthState.unauthenticated();
    }
    return const AuthState.authenticated();
  }

  /// Returns true when a valid (non-expired) access token exists.
  Future<bool> isAuthenticated() async {
    final state = await getAuthState();
    return state is Authenticated;
  }

  /// Log in with [email] and [password]. Stores tokens on success.
  Future<void> login({required String email, required String password}) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    final data = response.data!;
    await _tokenManager.saveTokens(
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
    );
  }

  /// Log out and clear all stored tokens.
  Future<void> logout() async {
    try {
      await _apiClient.post<void>('/auth/logout');
    } finally {
      await _tokenManager.clearTokens();
    }
  }

  /// Attempt to refresh the access token using the stored refresh token.
  /// Returns true on success.
  Future<bool> refreshToken() async {
    final refresh = await _tokenManager.getRefreshToken();
    if (refresh == null) return false;
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': refresh},
      );
      final data = response.data!;
      await _tokenManager.saveTokens(
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String,
      );
      return true;
    } catch (_) {
      await _tokenManager.clearTokens();
      return false;
    }
  }
}
