/// Dio interceptors for authentication, error handling, and logging.
library;

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../errors/shop_exceptions.dart';
import '../security/shop_session_manager.dart';

// ---------------------------------------------------------------------------
// Auth Interceptor
// ---------------------------------------------------------------------------

/// Attaches the JWT bearer token to every outgoing request and automatically
/// attempts a token refresh on a 401 Unauthorized response.
class ShopAuthInterceptor extends Interceptor {
  /// Creates a [ShopAuthInterceptor] backed by [sessionManager].
  ShopAuthInterceptor({required this.sessionManager});

  /// Provides access to stored tokens.
  final ShopSessionManager sessionManager;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await sessionManager.getAccessToken();
    if (token != null && token.isNotEmpty) {
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
      // Attempt a silent token refresh before surfacing the error.
      try {
        final refreshToken = await sessionManager.getRefreshToken();
        if (refreshToken == null || refreshToken.isEmpty) {
          return handler.next(err);
        }

        final refreshDio = Dio()
          ..options = BaseOptions(
            baseUrl: err.requestOptions.baseUrl,
            connectTimeout: const Duration(seconds: 10),
          );

        final response = await refreshDio.post<Map<String, dynamic>>(
          '/auth/refresh',
          data: {'refresh_token': refreshToken},
        );

        final newAccessToken = response.data?['access_token'] as String?;
        final newRefreshToken = response.data?['refresh_token'] as String?;

        if (newAccessToken != null) {
          await sessionManager.saveTokens(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken ?? refreshToken,
          );

          // Retry the original request with the new token.
          err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
          final retryDio = Dio();
          final retryResponse = await retryDio.fetch<dynamic>(err.requestOptions);
          return handler.resolve(retryResponse);
        }
      } catch (_) {
        // Refresh failed – clear the session and let the error propagate.
        await sessionManager.clearSession();
      }
    }
    handler.next(err);
  }
}

// ---------------------------------------------------------------------------
// Error Interceptor
// ---------------------------------------------------------------------------

/// Converts [DioException]s into typed [ShopException] subclasses so that
/// the rest of the codebase never has to depend on Dio directly.
class ShopErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final statusCode = err.response?.statusCode;
    final message = _extractMessage(err);

    final Exception shopException;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        shopException = TimeoutException(
          message: 'Request timed out. Please try again.',
          statusCode: statusCode,
        );

      case DioExceptionType.connectionError:
        shopException = NetworkException(
          message: 'No internet connection. Please check your network.',
          statusCode: statusCode,
        );

      case DioExceptionType.badResponse:
        if (statusCode == 401 || statusCode == 403) {
          shopException = AuthException(message: message, statusCode: statusCode);
        } else if (statusCode == 422) {
          shopException = ValidationException(message: message, statusCode: statusCode);
        } else if (statusCode != null && statusCode >= 500) {
          shopException = ServerException(message: message, statusCode: statusCode);
        } else {
          shopException = ServerException(message: message, statusCode: statusCode);
        }

      case DioExceptionType.cancel:
        shopException = NetworkException(message: 'Request was cancelled.');

      case DioExceptionType.unknown:
      case DioExceptionType.badCertificate:
        shopException = NetworkException(message: message);
    }

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: shopException,
        type: err.type,
        response: err.response,
      ),
    );
  }

  String _extractMessage(DioException err) {
    try {
      final data = err.response?.data;
      if (data is Map<String, dynamic>) {
        return (data['message'] as String?) ??
            (data['error'] as String?) ??
            err.message ??
            'An unexpected error occurred.';
      }
    } catch (_) {}
    return err.message ?? 'An unexpected error occurred.';
  }
}

// ---------------------------------------------------------------------------
// Logging Interceptor
// ---------------------------------------------------------------------------

/// Logs every request, response, and error using the [logger] package.
class ShopLoggingInterceptor extends Interceptor {
  /// Creates a [ShopLoggingInterceptor].
  ShopLoggingInterceptor({Logger? logger})
      : _logger = logger ?? Logger(printer: PrettyPrinter(methodCount: 0));

  final Logger _logger;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.i(
      '[ShopApi] --> ${options.method} ${options.uri}\n'
      'Headers: ${_sanitiseHeaders(options.headers)}\n'
      'Data: ${options.data}',
    );
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    _logger.i(
      '[ShopApi] <-- ${response.statusCode} ${response.requestOptions.uri}\n'
      'Data: ${response.data}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e(
      '[ShopApi] ERROR ${err.response?.statusCode} ${err.requestOptions.uri}',
      error: err.error ?? err.message,
    );
    handler.next(err);
  }

  /// Redacts the Authorization header value from logs.
  Map<String, dynamic> _sanitiseHeaders(Map<String, dynamic> headers) {
    final sanitised = Map<String, dynamic>.from(headers);
    if (sanitised.containsKey('Authorization')) {
      sanitised['Authorization'] = '[REDACTED]';
    }
    return sanitised;
  }
}
