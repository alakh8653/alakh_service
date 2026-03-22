/// Dio interceptors: auth token injection, logging, error mapping, and retry.
///
/// Add `dio` to your `pubspec.yaml`:
/// ```yaml
/// dependencies:
///   dio: ^5.4.0
/// ```
library api_interceptors;

// TODO: Uncomment when dio is added to pubspec.yaml
// import 'package:dio/dio.dart';

import '../utils/logger.dart';

// ── Auth Token Interceptor ────────────────────────────────────────────────────

/// Injects the Bearer access token into every outbound request and handles
/// 401 responses by transparently refreshing the token and retrying.
///
/// Usage:
/// ```dart
/// dio.interceptors.add(AuthTokenInterceptor(sessionManager: sl()));
/// ```
///
/// TODO: Uncomment and implement when `dio` and `session_manager` are wired up.
// class AuthTokenInterceptor extends Interceptor {
//   AuthTokenInterceptor({required this.sessionManager, required this.dio});
//
//   final SessionManager sessionManager;
//   final Dio dio;
//
//   @override
//   void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
//     final token = sessionManager.accessToken;
//     if (token != null) {
//       options.headers['Authorization'] = 'Bearer $token';
//     }
//     handler.next(options);
//   }
//
//   @override
//   Future<void> onError(
//     DioException err,
//     ErrorInterceptorHandler handler,
//   ) async {
//     if (err.response?.statusCode == 401) {
//       try {
//         await sessionManager.refreshToken();
//         final token = sessionManager.accessToken;
//         if (token != null) {
//           err.requestOptions.headers['Authorization'] = 'Bearer $token';
//           final response = await dio.fetch<dynamic>(err.requestOptions);
//           handler.resolve(response);
//           return;
//         }
//       } catch (_) {
//         sessionManager.invalidate();
//       }
//     }
//     handler.next(err);
//   }
// }

// ── Logging Interceptor ───────────────────────────────────────────────────────

/// Logs every request, response, and error to the app [AppLogger].
///
/// Automatically disabled in production builds when [enabled] is `false`.
///
/// TODO: Uncomment when `dio` is available.
// class LoggingInterceptor extends Interceptor {
//   LoggingInterceptor({this.enabled = true});
//
//   final bool enabled;
//   final _log = AppLogger('HTTP');
//
//   @override
//   void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
//     if (enabled) {
//       _log.d('→ ${options.method} ${options.uri}');
//     }
//     handler.next(options);
//   }
//
//   @override
//   void onResponse(Response response, ResponseInterceptorHandler handler) {
//     if (enabled) {
//       _log.d('← ${response.statusCode} ${response.requestOptions.uri}');
//     }
//     handler.next(response);
//   }
//
//   @override
//   void onError(DioException err, ErrorInterceptorHandler handler) {
//     if (enabled) {
//       _log.e('✗ ${err.requestOptions.uri}: ${err.message}');
//     }
//     handler.next(err);
//   }
// }

// ── Error Mapping Interceptor ─────────────────────────────────────────────────

/// Converts [DioException] types into domain-specific [AppNetworkException]s.
///
/// TODO: Uncomment when `dio` and `api_exceptions` are wired up.
// class ErrorMappingInterceptor extends Interceptor {
//   @override
//   void onError(DioException err, ErrorInterceptorHandler handler) {
//     final mapped = _map(err);
//     handler.reject(
//       DioException(
//         requestOptions: err.requestOptions,
//         error: mapped,
//         type: err.type,
//         response: err.response,
//       ),
//     );
//   }
//
//   AppNetworkException _map(DioException err) {
//     switch (err.type) {
//       case DioExceptionType.connectionTimeout:
//       case DioExceptionType.sendTimeout:
//       case DioExceptionType.receiveTimeout:
//         return TimeoutException(originalError: err);
//       case DioExceptionType.connectionError:
//         return NetworkException(originalError: err);
//       default:
//         final code = err.response?.statusCode;
//         return switch (code) {
//           401 => UnauthorizedException(originalError: err),
//           403 => ForbiddenException(originalError: err),
//           404 => NotFoundException(originalError: err),
//           422 => ValidationException(
//               originalError: err,
//               errors: _extractErrors(err.response?.data),
//             ),
//           429 => RateLimitException(originalError: err),
//           >= 500 => ServerException(statusCode: code, originalError: err),
//           _ => UnknownNetworkException(statusCode: code, originalError: err),
//         };
//     }
//   }
//
//   Map<String, List<String>> _extractErrors(dynamic data) {
//     if (data is! Map<String, dynamic>) return {};
//     final errors = data['errors'];
//     if (errors is! Map<String, dynamic>) return {};
//     return errors.map(
//       (k, v) => MapEntry(k, (v as List).map((e) => e.toString()).toList()),
//     );
//   }
// }

// ── Retry Interceptor ─────────────────────────────────────────────────────────

/// Retries failed requests up to [maxAttempts] times with exponential backoff.
///
/// Only retries on connection errors and 5xx responses. Does NOT retry 4xx.
///
/// TODO: Uncomment when `dio` is available.
// class RetryInterceptor extends Interceptor {
//   RetryInterceptor({
//     required this.dio,
//     this.maxAttempts = 3,
//     this.initialDelayMs = 500,
//   });
//
//   final Dio dio;
//   final int maxAttempts;
//   final int initialDelayMs;
//
//   static const _extraKey = '_retry_count';
//
//   @override
//   Future<void> onError(
//     DioException err,
//     ErrorInterceptorHandler handler,
//   ) async {
//     final attempt = (err.requestOptions.extra[_extraKey] as int?) ?? 0;
//     final isRetryable = _isRetryable(err);
//
//     if (isRetryable && attempt < maxAttempts) {
//       final delay = initialDelayMs * (1 << attempt); // exponential backoff
//       await Future<void>.delayed(Duration(milliseconds: delay));
//       err.requestOptions.extra[_extraKey] = attempt + 1;
//       try {
//         final response = await dio.fetch<dynamic>(err.requestOptions);
//         handler.resolve(response);
//         return;
//       } on DioException catch (retryErr) {
//         return onError(retryErr, handler);
//       }
//     }
//
//     handler.next(err);
//   }
//
//   bool _isRetryable(DioException err) =>
//       err.type == DioExceptionType.connectionError ||
//       err.type == DioExceptionType.connectionTimeout ||
//       (err.response?.statusCode ?? 0) >= 500;
// }

/// Placeholder class so the barrel file compiles without `dio`.
abstract final class ApiInterceptors {
  ApiInterceptors._();

  static final _log = AppLogger('ApiInterceptors');

  /// Log a message (used during development before Dio is wired up).
  static void logInfo(String msg) => _log.i(msg);
}
