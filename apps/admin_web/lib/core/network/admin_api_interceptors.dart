import 'package:dio/dio.dart';
import 'package:admin_web/core/security/admin_session_manager.dart';

class AuthInterceptor extends Interceptor {
  final AdminSessionManager _sessionManager;

  AuthInterceptor(this._sessionManager);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _sessionManager.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['Content-Type'] = 'application/json';
    options.headers['Accept'] = 'application/json';
    handler.next(options);
  }
}

class ErrorInterceptor extends Interceptor {
  final AdminSessionManager _sessionManager;
  final Dio _dio;

  ErrorInterceptor(this._sessionManager, this._dio);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;

    if (statusCode == 401) {
      final refreshed = await _tryRefreshToken(err, handler);
      if (refreshed) return;
      await _sessionManager.clearSession();
    }

    handler.next(err);
  }

  Future<bool> _tryRefreshToken(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final refreshToken = _sessionManager.getRefreshToken();
    if (refreshToken == null) return false;

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/admin/auth/refresh',
        data: {'refreshToken': refreshToken},
        options: Options(
          headers: {'Authorization': null},
        ),
      );

      final newToken = response.data?['token'] as String?;
      if (newToken == null) return false;

      final user = _sessionManager.getUser();
      if (user != null) {
        await _sessionManager.saveSession(
          newToken,
          response.data?['refreshToken'] as String? ?? refreshToken,
          user,
        );
      }

      final retryRequest = err.requestOptions;
      retryRequest.headers['Authorization'] = 'Bearer $newToken';
      final retryResponse = await _dio.fetch<dynamic>(retryRequest);
      handler.resolve(retryResponse);
      return true;
    } catch (_) {
      return false;
    }
  }
}

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(err);
  }
}
