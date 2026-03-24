/// User session management with token refresh logic.
library session_manager;

import 'dart:async';

import '../utils/logger.dart';
import 'secure_storage.dart';

/// Keys used to persist session data in [SecureStorage].
abstract final class _SessionKeys {
  static const String accessToken = 'session_access_token';
  static const String refreshToken = 'session_refresh_token';
  static const String userId = 'session_user_id';
  static const String expiresAt = 'session_expires_at';
}

/// Manages the user's authentication session, including:
/// - Persisting tokens in [SecureStorage].
/// - Exposing a stream of session state changes.
/// - Providing a [refreshToken] hook used by the auth interceptor.
class SessionManager {
  SessionManager({required SecureStorage secureStorage})
      : _storage = secureStorage;

  final SecureStorage _storage;
  final _log = AppLogger('SessionManager');
  final _stateController = StreamController<SessionState>.broadcast();

  SessionState _state = const UnauthenticatedState();

  // ── State ─────────────────────────────────────────────────────────────────

  /// Current session state.
  SessionState get state => _state;

  /// Stream that emits whenever the session state changes.
  Stream<SessionState> get onStateChange => _stateController.stream;

  /// Returns `true` when the user has a valid, non-expired access token.
  bool get isAuthenticated => _state is AuthenticatedState;

  /// The current access token, or `null` if unauthenticated.
  String? get accessToken =>
      _state is AuthenticatedState
          ? (_state as AuthenticatedState).accessToken
          : null;

  // ── Session lifecycle ─────────────────────────────────────────────────────

  /// Restores the session from [SecureStorage] on app startup.
  Future<void> restore() async {
    final token = await _storage.read(_SessionKeys.accessToken);
    final refresh = await _storage.read(_SessionKeys.refreshToken);
    final userId = await _storage.read(_SessionKeys.userId);
    final expiresAtStr = await _storage.read(_SessionKeys.expiresAt);

    if (token == null || userId == null) {
      _log.i('No persisted session found');
      _updateState(const UnauthenticatedState());
      return;
    }

    final expiresAt = expiresAtStr != null
        ? DateTime.tryParse(expiresAtStr)
        : null;

    if (expiresAt != null && expiresAt.isBefore(DateTime.now().toUtc())) {
      _log.i('Persisted token expired – clearing session');
      await invalidate();
      return;
    }

    _updateState(AuthenticatedState(
      userId: userId,
      accessToken: token,
      refreshToken: refresh,
      expiresAt: expiresAt,
    ));
    _log.i('Session restored for user: $userId');
  }

  /// Saves a new session after a successful login or token refresh.
  Future<void> save({
    required String userId,
    required String accessToken,
    String? refreshToken,
    DateTime? expiresAt,
  }) async {
    await _storage.write(_SessionKeys.accessToken, accessToken);
    await _storage.write(_SessionKeys.userId, userId);
    if (refreshToken != null) {
      await _storage.write(_SessionKeys.refreshToken, refreshToken);
    }
    if (expiresAt != null) {
      await _storage.write(
        _SessionKeys.expiresAt,
        expiresAt.toUtc().toIso8601String(),
      );
    }

    _updateState(AuthenticatedState(
      userId: userId,
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: expiresAt,
    ));
    _log.i('Session saved for user: $userId');
  }

  /// Clears the session (call on logout or token invalidation).
  Future<void> invalidate() async {
    await _storage.delete(_SessionKeys.accessToken);
    await _storage.delete(_SessionKeys.refreshToken);
    await _storage.delete(_SessionKeys.userId);
    await _storage.delete(_SessionKeys.expiresAt);
    _updateState(const UnauthenticatedState());
    _log.i('Session invalidated');
  }

  /// Attempts to refresh the access token using the stored refresh token.
  ///
  /// Returns the new access token on success, or throws on failure.
  ///
  /// TODO: Inject an [ApiClient] and call the refresh endpoint.
  Future<String> refreshToken() async {
    final currentState = _state;
    if (currentState is! AuthenticatedState) {
      throw StateError('Cannot refresh – no active session');
    }
    final token = currentState.refreshToken;
    if (token == null) {
      throw StateError('No refresh token available');
    }

    // TODO: Call the refresh endpoint:
    // final response = await _apiClient.post<Map<String, dynamic>>(
    //   ApiEndpoints.refreshToken,
    //   data: {'refresh_token': token},
    // );
    // if (response.isSuccess) {
    //   final data = response.dataOrNull!;
    //   await save(
    //     userId: currentState.userId,
    //     accessToken: data['access_token'],
    //     refreshToken: data['refresh_token'],
    //     expiresAt: DateTime.parse(data['expires_at']),
    //   );
    //   return data['access_token'];
    // }
    // await invalidate();
    // throw AuthFailure();

    _log.w('refreshToken – stub: invalidating session');
    await invalidate();
    throw StateError('Token refresh not yet implemented');
  }

  // ── Private ───────────────────────────────────────────────────────────────

  void _updateState(SessionState newState) {
    _state = newState;
    if (!_stateController.isClosed) {
      _stateController.add(newState);
    }
  }

  /// Releases resources.
  Future<void> dispose() => _stateController.close();
}

// ── Session state types ───────────────────────────────────────────────────────

/// Base session state.
sealed class SessionState {
  const SessionState();
}

/// Represents an active, authenticated session.
final class AuthenticatedState extends SessionState {
  const AuthenticatedState({
    required this.userId,
    required this.accessToken,
    this.refreshToken,
    this.expiresAt,
  });

  final String userId;
  final String accessToken;
  final String? refreshToken;
  final DateTime? expiresAt;

  /// Whether the access token has passed its expiry time.
  bool get isTokenExpired =>
      expiresAt != null && expiresAt!.isBefore(DateTime.now().toUtc());
}

/// Represents a session where no user is logged in.
final class UnauthenticatedState extends SessionState {
  const UnauthenticatedState();
}
