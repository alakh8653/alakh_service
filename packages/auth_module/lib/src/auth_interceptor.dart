import 'package:dio/dio.dart';

import 'auth_manager.dart';

/// Dio interceptor that automatically injects the Authorization header and
/// handles 401 responses by attempting a silent token refresh and retrying the
/// original request.
///
/// Add this interceptor to your [Dio] instance:
/// ```dart
/// dio.interceptors.add(AuthDioInterceptor(authManager));
/// ```
///
/// To skip auth injection for a specific request (e.g. login, token refresh
/// endpoints), set `extra: {'skipAuth': true}` in the request options.
class AuthDioInterceptor extends Interceptor {
  final AuthManager _authManager;

  /// Creates an [AuthDioInterceptor] driven by the given [authManager].
  AuthDioInterceptor(this._authManager);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra['skipAuth'] == true) {
      return handler.next(options);
    }

    final token = await _authManager.getValidAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      final refreshed = await _authManager.refreshToken();
      if (refreshed) {
        final token = await _authManager.getValidAccessToken();
        final opts = err.requestOptions;
        if (token != null) {
          opts.headers['Authorization'] = 'Bearer $token';
        }
        try {
          final response = await Dio().fetch(opts);
          return handler.resolve(response);
        } catch (_) {
          // Retry failed — fall through to logout.
        }
      }
      // Refresh or retry failed: force the user back to the login screen.
      await _authManager.logout();
    }
    handler.next(err);
  }
}
