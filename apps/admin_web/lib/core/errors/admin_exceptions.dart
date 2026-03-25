class ServerException implements Exception {
  final String message;
  const ServerException(this.message);

  @override
  String toString() => 'ServerException: $message';
}

class NetworkException implements Exception {
  final String message;
  const NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

class UnauthorizedException implements Exception {
  final String message;
  const UnauthorizedException(this.message);

  @override
  String toString() => 'UnauthorizedException: $message';
}

class NotFoundException implements Exception {
  final String message;
  const NotFoundException(this.message);

  @override
  String toString() => 'NotFoundException: $message';
}

class ValidationException implements Exception {
  final String message;
  const ValidationException(this.message);

  @override
  String toString() => 'ValidationException: $message';
}

class CacheException implements Exception {
  final String message;
  const CacheException(this.message);

  @override
  String toString() => 'CacheException: $message';
}

class ForbiddenException implements Exception {
  final String message;
  const ForbiddenException(this.message);

  @override
  String toString() => 'ForbiddenException: $message';
}
