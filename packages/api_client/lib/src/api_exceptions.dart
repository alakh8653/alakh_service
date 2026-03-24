/// Base class for all API exceptions thrown by [ApiClient].
sealed class ApiException implements Exception {
  const ApiException(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Thrown when the server returns HTTP 401 Unauthorized.
class UnauthorizedException extends ApiException {
  const UnauthorizedException(super.message);
}

/// Thrown when the server returns HTTP 403 Forbidden.
class ForbiddenException extends ApiException {
  const ForbiddenException(super.message);
}

/// Thrown when the server returns HTTP 404 Not Found.
class NotFoundException extends ApiException {
  const NotFoundException(super.message);
}

/// Thrown when the server returns HTTP 422 Unprocessable Entity.
class ValidationException extends ApiException {
  const ValidationException(super.message, {this.errors});
  final Map<String, dynamic>? errors;
}

/// Thrown when the server returns a 5xx error.
class ServerException extends ApiException {
  const ServerException(super.message);
}

/// Thrown on network connectivity issues.
class NetworkException extends ApiException {
  const NetworkException(super.message);
}
