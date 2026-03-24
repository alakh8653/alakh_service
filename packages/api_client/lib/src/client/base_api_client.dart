import 'package:dio/dio.dart';

import '../exceptions/api_exception.dart';
import '../exceptions/forbidden_exception.dart';
import '../exceptions/network_exception.dart';
import '../exceptions/not_found_exception.dart';
import '../exceptions/rate_limit_exception.dart';
import '../exceptions/server_exception.dart';
import '../exceptions/timeout_exception.dart';
import '../exceptions/unauthorized_exception.dart';
import '../exceptions/validation_exception.dart';
import '../models/api_error_response.dart';
import 'api_client_config.dart';

/// Abstract base class for all API clients in the application.
///
/// Provides a pre-configured [Dio] instance and helper methods for the most
/// common HTTP verbs. Subclasses should add interceptors and domain-specific
/// methods via [dio].
abstract class BaseApiClient {
  /// The underlying Dio HTTP client.
  final Dio dio;

  /// The configuration used to initialise this client.
  final ApiClientConfig config;

  /// Creates a [BaseApiClient] and configures the [Dio] instance from [config].
  BaseApiClient(this.config)
      : dio = Dio(
          BaseOptions(
            baseUrl: config.baseUrl,
            connectTimeout: config.connectTimeout,
            receiveTimeout: config.receiveTimeout,
            sendTimeout: config.sendTimeout,
            headers: config.defaultHeaders,
          ),
        );

  // ---------------------------------------------------------------------------
  // HTTP helpers
  // ---------------------------------------------------------------------------

  /// Sends a GET request to [path].
  ///
  /// [queryParameters] are appended to the URL.
  /// [options] allow per-request overrides (e.g. extra headers).
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Sends a POST request to [path] with an optional [data] body.
  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Sends a PUT request to [path] with an optional [data] body.
  Future<T> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Sends a PATCH request to [path] with an optional [data] body.
  Future<T> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Sends a DELETE request to [path].
  Future<T> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Error handling
  // ---------------------------------------------------------------------------

  /// Converts a [DioException] into the appropriate [ApiException] subclass.
  ApiException _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return RequestTimeoutException(
          message: 'The request timed out. Please try again.',
          statusCode: e.response?.statusCode,
          data: e.response?.data,
        );

      case DioExceptionType.connectionError:
        return NetworkException(
          message:
              'No internet connection or the server could not be reached.',
          data: e.error,
        );

      case DioExceptionType.badResponse:
        return _handleBadResponse(e);

      case DioExceptionType.cancel:
        return ApiException(
          message: 'Request was cancelled.',
          statusCode: e.response?.statusCode,
        );

      default:
        return ApiException(
          message: e.message ?? 'An unexpected error occurred.',
          statusCode: e.response?.statusCode,
          data: e.response?.data,
        );
    }
  }

  /// Maps HTTP status codes to typed [ApiException] subclasses.
  ApiException _handleBadResponse(DioException e) {
    final statusCode = e.response?.statusCode;
    final responseData = e.response?.data;

    ApiErrorResponse? errorResponse;
    if (responseData is Map<String, dynamic>) {
      try {
        errorResponse = ApiErrorResponse.fromJson(responseData);
      } catch (_) {
        // Ignore parsing errors — fall back to generic messages.
      }
    }

    final message = errorResponse?.message ?? _defaultMessageFor(statusCode);

    switch (statusCode) {
      case 401:
        return UnauthorizedException(
          message: message,
          statusCode: statusCode,
          data: responseData,
        );
      case 403:
        return ForbiddenException(
          message: message,
          statusCode: statusCode,
          data: responseData,
        );
      case 404:
        return NotFoundException(
          message: message,
          statusCode: statusCode,
          data: responseData,
        );
      case 422:
        return ValidationException(
          message: message,
          statusCode: statusCode,
          data: responseData,
          fieldErrors: errorResponse?.fieldErrors ?? const {},
        );
      case 429:
        return RateLimitException(
          message: message,
          statusCode: statusCode,
          data: responseData,
        );
      default:
        if (statusCode != null && statusCode >= 500) {
          return ServerException(
            message: message,
            statusCode: statusCode,
            data: responseData,
          );
        }
        return ApiException(
          message: message,
          statusCode: statusCode,
          data: responseData,
        );
    }
  }

  String _defaultMessageFor(int? statusCode) {
    switch (statusCode) {
      case 401:
        return 'Authentication required.';
      case 403:
        return 'You do not have permission to perform this action.';
      case 404:
        return 'The requested resource was not found.';
      case 422:
        return 'Validation failed.';
      case 429:
        return 'Too many requests. Please slow down.';
      default:
        if (statusCode != null && statusCode >= 500) {
          return 'A server error occurred. Please try again later.';
        }
        return 'An unexpected error occurred (HTTP $statusCode).';
    }
  }
}
