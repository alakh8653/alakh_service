/// Custom exception types for the Shop Web application.
///
/// These exceptions are thrown by the data and network layers and are
/// converted into [Failure] objects by [ShopErrorHandler] before reaching
/// the domain / presentation layers.
library;

/// Thrown when a network-level error occurs (no connectivity, DNS failure, etc).
class NetworkException implements Exception {
  /// Creates a [NetworkException].
  const NetworkException({
    required this.message,
    this.statusCode,
  });

  /// Human-readable description of the error.
  final String message;

  /// Optional HTTP status code associated with the failure.
  final int? statusCode;

  @override
  String toString() => 'NetworkException(statusCode: $statusCode, message: $message)';
}

/// Thrown when authentication or authorisation fails.
class AuthException implements Exception {
  /// Creates an [AuthException].
  const AuthException({
    required this.message,
    this.statusCode,
  });

  /// Human-readable description of the error.
  final String message;

  /// Optional HTTP status code (e.g. 401, 403).
  final int? statusCode;

  @override
  String toString() => 'AuthException(statusCode: $statusCode, message: $message)';
}

/// Thrown when the remote server returns an unexpected error response.
class ServerException implements Exception {
  /// Creates a [ServerException].
  const ServerException({
    required this.message,
    this.statusCode,
  });

  /// Human-readable description of the error.
  final String message;

  /// Optional HTTP status code (e.g. 500, 503).
  final int? statusCode;

  @override
  String toString() => 'ServerException(statusCode: $statusCode, message: $message)';
}

/// Thrown when reading from or writing to a local cache fails.
class CacheException implements Exception {
  /// Creates a [CacheException].
  const CacheException({
    required this.message,
    this.statusCode,
  });

  /// Human-readable description of the error.
  final String message;

  /// Optional error code from the underlying storage library.
  final int? statusCode;

  @override
  String toString() => 'CacheException(statusCode: $statusCode, message: $message)';
}

/// Thrown when input data fails a validation check.
class ValidationException implements Exception {
  /// Creates a [ValidationException].
  const ValidationException({
    required this.message,
    this.statusCode,
    this.fieldErrors = const {},
  });

  /// Human-readable description of the validation error.
  final String message;

  /// Optional status code (typically 422 from the server).
  final int? statusCode;

  /// Per-field validation messages keyed by field name.
  final Map<String, String> fieldErrors;

  @override
  String toString() =>
      'ValidationException(statusCode: $statusCode, message: $message, '
      'fieldErrors: $fieldErrors)';
}

/// Thrown when a network or database operation exceeds its time limit.
class TimeoutException implements Exception {
  /// Creates a [TimeoutException].
  const TimeoutException({
    required this.message,
    this.statusCode,
  });

  /// Human-readable description of the error.
  final String message;

  /// Optional status code (e.g. 408 Request Timeout).
  final int? statusCode;

  @override
  String toString() => 'TimeoutException(statusCode: $statusCode, message: $message)';
}
