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

/// Dio interceptor that converts [DioException]s into typed [ApiException]s.
///
/// This interceptor runs in the error pipeline and re-throws domain exceptions
/// so that callers never need to handle raw [DioException] values.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: _mapException(err),
        message: err.message,
      ),
    );
  }

  ApiException _mapException(DioException e) {
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
        return _mapStatusCode(e);

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

  ApiException _mapStatusCode(DioException e) {
    final statusCode = e.response?.statusCode;
    final responseData = e.response?.data;

    ApiErrorResponse? errorResponse;
    if (responseData is Map<String, dynamic>) {
      try {
        errorResponse = ApiErrorResponse.fromJson(responseData);
      } catch (_) {}
    }

    final message = errorResponse?.message ?? _defaultMessage(statusCode);

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
        final retryAfterHeader =
            e.response?.headers.value('Retry-After');
        final retryAfter = retryAfterHeader != null
            ? Duration(seconds: int.tryParse(retryAfterHeader) ?? 60)
            : null;
        return RateLimitException(
          message: message,
          statusCode: statusCode,
          data: responseData,
          retryAfter: retryAfter,
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

  String _defaultMessage(int? statusCode) {
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
