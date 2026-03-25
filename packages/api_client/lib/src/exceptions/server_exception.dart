import 'api_exception.dart';

/// Thrown when the server responds with a 5xx status code.
class ServerException extends ApiException {
  const ServerException({
    super.message = 'A server error occurred. Please try again later.',
    super.statusCode,
    super.data,
  });

  @override
  String toString() => 'ServerException(${statusCode ?? '5xx'}): $message';
}
