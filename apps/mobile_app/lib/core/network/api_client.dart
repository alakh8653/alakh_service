/// HTTP client wrapper using Dio.
///
/// Add `dio` to your `pubspec.yaml`:
/// ```yaml
/// dependencies:
///   dio: ^5.4.0
/// ```
library api_client;

import '../config/app_config.dart';
import '../utils/logger.dart';
import 'api_exceptions.dart';
import 'api_response.dart';

// TODO: Uncomment when dio is added to pubspec.yaml
// import 'package:dio/dio.dart';
// import 'api_interceptors.dart';

/// Abstract interface for the HTTP client.
///
/// Depends on [ApiResponse] so callers are always shielded from raw Dio /
/// http types.
abstract class ApiClient {
  /// Performs a GET request.
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
  });

  /// Performs a POST request.
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
  });

  /// Performs a PUT request.
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
  });

  /// Performs a PATCH request.
  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
  });

  /// Performs a DELETE request.
  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
  });
}

/// [ApiClient] implementation that wraps Dio.
///
/// Registers:
/// - [AuthTokenInterceptor]  — Bearer token injection + silent token refresh
/// - [LoggingInterceptor]    — Request / response logging
/// - [ErrorMappingInterceptor] — DioException → AppNetworkException
/// - [RetryInterceptor]      — Exponential-backoff retry for 5xx + network errors
class DioApiClient implements ApiClient {
  DioApiClient({
    required AppConfig config,
    // TODO: uncomment when SessionManager is wired up
    // required SessionManager sessionManager,
  }) : _config = config {
    _log.i('DioApiClient initialised – baseUrl: ${_config.fullBaseUrl}');
    _initDio();
  }

  final AppConfig _config;
  final _log = AppLogger('ApiClient');

  // TODO: Replace with a real Dio instance:
  // late final Dio _dio;

  void _initDio() {
    // TODO: Remove comment and uncomment body when dio is available:
    //
    // _dio = Dio(
    //   BaseOptions(
    //     baseUrl: _config.fullBaseUrl,
    //     connectTimeout: Duration(milliseconds: _config.connectionTimeoutMs),
    //     receiveTimeout: Duration(milliseconds: _config.receiveTimeoutMs),
    //     headers: {
    //       'Accept': 'application/json',
    //       'Content-Type': 'application/json',
    //       if (_config.apiKey.isNotEmpty) 'X-Api-Key': _config.apiKey,
    //     },
    //   ),
    // );
    //
    // _dio.interceptors.addAll([
    //   AuthTokenInterceptor(sessionManager: sessionManager, dio: _dio),
    //   if (_config.enableLogging) LoggingInterceptor(enabled: true),
    //   ErrorMappingInterceptor(),
    //   RetryInterceptor(dio: _dio, maxAttempts: _config.maxRetryAttempts),
    // ]);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  // TODO: Replace with real implementation using Dio:
  // ApiResponse<T> _handleResponse<T>(
  //   Response<dynamic> response,
  //   T Function(Map<String, dynamic>)? fromJson,
  // ) {
  //   final statusCode = response.statusCode ?? 200;
  //   final body = response.data;
  //   if (body is Map<String, dynamic>) {
  //     final data = fromJson != null ? fromJson(body['data'] ?? body) : body as T;
  //     return SuccessResponse<T>(data: data, statusCode: statusCode);
  //   }
  //   return ErrorResponse<T>(message: 'Unexpected response format', statusCode: statusCode);
  // }
  //
  // ApiResponse<T> _handleError<T>(DioException err) {
  //   final exception = err.error;
  //   if (exception is AppNetworkException) {
  //     return ErrorResponse<T>(
  //       message: exception.message,
  //       statusCode: exception.statusCode,
  //     );
  //   }
  //   return ErrorResponse<T>(message: err.message ?? 'Unknown error');
  // }

  // ── Interface implementation (stubs until Dio is wired up) ───────────────

  @override
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    _log.d('GET $path');
    // TODO: Replace stub with: return _execute(() => _dio.get(path, queryParameters: queryParameters), fromJson);
    return ErrorResponse<T>(message: 'DioApiClient not yet initialised – add dio dependency.');
  }

  @override
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    _log.d('POST $path');
    return ErrorResponse<T>(message: 'DioApiClient not yet initialised – add dio dependency.');
  }

  @override
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    _log.d('PUT $path');
    return ErrorResponse<T>(message: 'DioApiClient not yet initialised – add dio dependency.');
  }

  @override
  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    _log.d('PATCH $path');
    return ErrorResponse<T>(message: 'DioApiClient not yet initialised – add dio dependency.');
  }

  @override
  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    _log.d('DELETE $path');
    return ErrorResponse<T>(message: 'DioApiClient not yet initialised – add dio dependency.');
  }
}
