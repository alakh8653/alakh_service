import 'dart:async';

import 'auth_exceptions.dart';
import 'auth_state.dart';
import 'auth_storage.dart';
import 'auth_token.dart';
import 'token_refresher.dart';

/// Central hub for authentication state across the app lifecycle.
///
/// [AuthManager] owns the canonical [AuthState] stream and is the single
/// point of contact for login, logout, and token-refresh operations. Consumers
/// can listen to [stateStream] to react to state changes, or read
/// [currentState] synchronously.
class AuthManager {
  final AuthStorage _storage;
  final TokenRefresher _refresher;

  final _stateController = StreamController<AuthState>.broadcast();
  AuthState _currentState = const AuthInitial();

  /// Creates an [AuthManager].
  ///
  /// [storage] provides persistent token storage.
  /// [refresher] handles token renewal.
  AuthManager({
    required AuthStorage storage,
    required TokenRefresher refresher,
  })  : _storage = storage,
        _refresher = refresher;

  /// A broadcast stream that emits a new [AuthState] whenever authentication
  /// state changes.
  Stream<AuthState> get stateStream => _stateController.stream;

  /// The most recently emitted [AuthState].
  AuthState get currentState => _currentState;

  /// `true` when [currentState] is [Authenticated].
  bool get isAuthenticated => _currentState is Authenticated;

  /// Reads any persisted token and transitions to [Authenticated] if one
  /// exists and is not expired, or [Unauthenticated] otherwise.
  ///
  /// Should be called once at app startup before the UI is shown.
  Future<void> initialize() async {
    _emit(const AuthLoading());
    try {
      final token = await _storage.getToken();
      if (token == null) {
        _emit(const Unauthenticated());
        return;
      }

      if (token.isExpired) {
        // Attempt a silent refresh before giving up.
        final refreshed = await refreshToken();
        if (!refreshed) {
          await _storage.deleteToken();
          _emit(const Unauthenticated());
        }
        return;
      }

      _emit(Authenticated(userId: '', token: token));
    } catch (e) {
      _emit(const Unauthenticated());
    }
  }

  /// Stores [token] and transitions to [Authenticated].
  ///
  /// [userId], [email], and [phone] are optional profile fields surfaced in
  /// the [Authenticated] state.
  Future<void> loginWithToken(
    AuthToken token, {
    String? userId,
    String? email,
    String? phone,
  }) async {
    _emit(const AuthLoading());
    try {
      await _storage.saveToken(token);
      _emit(Authenticated(
        userId: userId ?? '',
        token: token,
        email: email,
        phone: phone,
      ));
    } catch (e) {
      final exception = e is AuthException
          ? e
          : AuthException == e.runtimeType
              ? e as AuthException
              : TokenRefreshFailedException(e.toString());
      _emit(AuthError(exception as AuthException));
      rethrow;
    }
  }

  /// Deletes the stored token and transitions to [Unauthenticated].
  Future<void> logout() async {
    try {
      await _storage.deleteToken();
    } finally {
      _emit(const Unauthenticated());
    }
  }

  /// Attempts to obtain a new token using the stored refresh token.
  ///
  /// Returns `true` if the refresh succeeded and [currentState] was updated
  /// to the new [Authenticated] state; `false` otherwise.
  Future<bool> refreshToken() async {
    try {
      final newToken = await _refresher.refresh();
      if (newToken == null) return false;

      final previous = _currentState;
      final userId = previous is Authenticated ? previous.userId : '';
      final email = previous is Authenticated ? previous.email : null;
      final phone = previous is Authenticated ? previous.phone : null;

      _emit(Authenticated(
        userId: userId,
        token: newToken,
        email: email,
        phone: phone,
      ));
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Returns the current access token string, automatically refreshing it if
  /// it is about to expire or has already expired.
  ///
  /// Returns `null` when no token is available or the refresh fails.
  Future<String?> getValidAccessToken() async {
    final state = _currentState;
    if (state is! Authenticated) return null;

    if (state.token.isAboutToExpire) {
      final refreshed = await refreshToken();
      if (!refreshed) return null;
      final updated = _currentState;
      return updated is Authenticated ? updated.token.accessToken : null;
    }

    return state.token.accessToken;
  }

  /// Releases resources held by this manager. Must be called when the manager
  /// is no longer needed.
  void dispose() {
    _stateController.close();
  }

  void _emit(AuthState state) {
    _currentState = state;
    if (!_stateController.isClosed) {
      _stateController.add(state);
    }
  }
}
