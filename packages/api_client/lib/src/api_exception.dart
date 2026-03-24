sealed class ApiException implements Exception {
  const ApiException({required this.message, this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => '$runtimeType: $message (status: $statusCode)';
}

final class NetworkException extends ApiException {
  const NetworkException({required super.message}) : super(statusCode: null);
}

final class ServerException extends ApiException {
  const ServerException({required super.message, required int statusCode})
      : super(statusCode: statusCode);
}

final class UnauthorizedException extends ApiException {
  const UnauthorizedException({super.message = 'Unauthorized'})
      : super(statusCode: 401);
}

final class ForbiddenException extends ApiException {
  const ForbiddenException({super.message = 'Forbidden'})
      : super(statusCode: 403);
}

final class NotFoundException extends ApiException {
  const NotFoundException({super.message = 'Resource not found'})
      : super(statusCode: 404);
}

final class ValidationException extends ApiException {
  const ValidationException({
    required super.message,
    this.errors = const {},
  }) : super(statusCode: 422);

  final Map<String, List<String>> errors;
}

final class TimeoutException extends ApiException {
  const TimeoutException({super.message = 'Request timed out'})
      : super(statusCode: null);
}

final class UnknownException extends ApiException {
  const UnknownException({required super.message}) : super(statusCode: null);
}
