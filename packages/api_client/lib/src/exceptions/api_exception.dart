/// Base exception for all API-related errors.
///
/// Every typed exception in this package extends [ApiException], allowing
/// callers to catch all API errors with a single `on ApiException` clause
/// while still being able to handle specific cases (e.g. [UnauthorizedException]).
class ApiException implements Exception {
  /// Human-readable description of the error.
  final String message;

  /// The HTTP status code associated with this error, if any.
  final int? statusCode;

  /// The raw response data, if available.
  final dynamic data;

  const ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() {
    final code = statusCode != null ? ' (HTTP $statusCode)' : '';
    return 'ApiException$code: $message';
  }
}
