/// Custom exception hierarchy for network / API errors.
///
/// All exceptions extend [AppNetworkException] which itself implements
/// [Exception], so callers can catch either the base or specific type.
library api_exceptions;

/// Base class for all network-related exceptions.
sealed class AppNetworkException implements Exception {
  const AppNetworkException({
    required this.message,
    this.statusCode,
    this.originalError,
  });

  /// Human-readable message describing the error.
  final String message;

  /// HTTP status code, if available.
  final int? statusCode;

  /// The underlying exception / error object, if any.
  final Object? originalError;

  @override
  String toString() =>
      '${runtimeType}(statusCode: $statusCode, message: $message)';
}

/// Thrown when there is no internet connectivity.
final class NetworkException extends AppNetworkException {
  const NetworkException({
    super.message = 'No internet connection. Please check your network.',
    super.statusCode,
    super.originalError,
  });
}

/// Thrown when the server returns a 5xx response.
final class ServerException extends AppNetworkException {
  const ServerException({
    super.message = 'An unexpected server error occurred. Please try again.',
    super.statusCode,
    super.originalError,
  });
}

/// Thrown when the server returns 401 Unauthorized.
final class UnauthorizedException extends AppNetworkException {
  const UnauthorizedException({
    super.message = 'Your session has expired. Please log in again.',
    super.statusCode = 401,
    super.originalError,
  });
}

/// Thrown when the server returns 403 Forbidden.
final class ForbiddenException extends AppNetworkException {
  const ForbiddenException({
    super.message = 'You do not have permission to perform this action.',
    super.statusCode = 403,
    super.originalError,
  });
}

/// Thrown when the server returns 404 Not Found.
final class NotFoundException extends AppNetworkException {
  const NotFoundException({
    super.message = 'The requested resource was not found.',
    super.statusCode = 404,
    super.originalError,
  });
}

/// Thrown when the request or connection times out.
final class TimeoutException extends AppNetworkException {
  const TimeoutException({
    super.message = 'The request timed out. Please try again.',
    super.statusCode,
    super.originalError,
  });
}

/// Thrown when the server returns 422 Unprocessable Entity (validation errors).
final class ValidationException extends AppNetworkException {
  const ValidationException({
    super.message = 'Validation failed.',
    super.statusCode = 422,
    super.originalError,
    this.errors = const {},
  });

  /// Field-level validation errors returned by the server.
  ///
  /// Keys are field names; values are lists of error messages.
  final Map<String, List<String>> errors;

  @override
  String toString() =>
      'ValidationException(statusCode: $statusCode, errors: $errors)';
}

/// Thrown when the server returns 429 Too Many Requests.
final class RateLimitException extends AppNetworkException {
  const RateLimitException({
    super.message = 'Too many requests. Please slow down and try again.',
    super.statusCode = 429,
    super.originalError,
    this.retryAfterSeconds,
  });

  /// Number of seconds to wait before retrying, if provided by the server.
  final int? retryAfterSeconds;
}

/// Thrown when response JSON cannot be parsed into the expected model.
final class ParseException extends AppNetworkException {
  const ParseException({
    super.message = 'Failed to parse the server response.',
    super.statusCode,
    super.originalError,
  });
}

/// Thrown for any other unhandled HTTP / network error.
final class UnknownNetworkException extends AppNetworkException {
  const UnknownNetworkException({
    super.message = 'An unknown network error occurred.',
    super.statusCode,
    super.originalError,
  });
}
