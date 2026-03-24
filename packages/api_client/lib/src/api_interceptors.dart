import 'package:dio/dio.dart';

/// Interceptor that attaches the JWT access token to every outgoing request
/// and handles transparent token refresh on 401 responses.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    this.getAccessToken,
    this.refreshToken,
  });

  final String? Function()? getAccessToken;
  final Future<String?> Function()? refreshToken;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = getAccessToken?.call();
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
    if (err.response?.statusCode == 401 && refreshToken != null) {
      try {
        final newToken = await refreshToken!();
        if (newToken != null) {
          final opts = err.requestOptions
            ..headers['Authorization'] = 'Bearer $newToken';
          final response = await Dio().fetch<dynamic>(opts);
          return handler.resolve(response);
        }
      } catch (_) {
        // Refresh failed — propagate original error
      }
    }
    handler.next(err);
  }
}
