import 'dart:async';

import 'auth_storage.dart';
import 'auth_token.dart';

/// Handles token refresh with a lock mechanism that prevents duplicate
/// concurrent refresh requests.
///
/// When multiple callers invoke [refresh] simultaneously only one network
/// request is made; all other callers await the same [Completer] and receive
/// the same result.
class TokenRefresher {
  final Future<AuthToken?> Function(String refreshToken) _refreshFn;
  final AuthStorage _storage;

  bool _isRefreshing = false;
  Completer<AuthToken?>? _refreshCompleter;

  /// Creates a [TokenRefresher].
  ///
  /// [refreshFn] performs the actual network call to exchange a refresh token
  /// for a new [AuthToken]. It receives the current refresh token and must
  /// return the new [AuthToken] on success, or `null` if the token is invalid.
  ///
  /// [storage] is used to read the current token before refreshing and to
  /// persist the new token after a successful refresh.
  TokenRefresher({
    required Future<AuthToken?> Function(String refreshToken) refreshFn,
    required AuthStorage storage,
  })  : _refreshFn = refreshFn,
        _storage = storage;

  /// Refreshes the stored token.
  ///
  /// If a refresh is already in progress the caller awaits the existing
  /// [Completer] rather than triggering a second request.
  ///
  /// Returns the new [AuthToken] on success, or `null` if there is no stored
  /// token or the server rejects the refresh token.
  ///
  /// Throws if [refreshFn] throws.
  Future<AuthToken?> refresh() async {
    if (_isRefreshing) {
      return _refreshCompleter!.future;
    }

    _isRefreshing = true;
    _refreshCompleter = Completer<AuthToken?>();

    try {
      final currentToken = await _storage.getToken();
      if (currentToken == null) {
        _refreshCompleter!.complete(null);
        return null;
      }

      final newToken = await _refreshFn(currentToken.refreshToken);
      if (newToken != null) {
        await _storage.saveToken(newToken);
      }
      _refreshCompleter!.complete(newToken);
      return newToken;
    } catch (e) {
      _refreshCompleter!.completeError(e);
      rethrow;
    } finally {
      _isRefreshing = false;
      _refreshCompleter = null;
    }
  }
}
