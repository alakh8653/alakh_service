import 'api_exception.dart';

/// Thrown when the server responds with HTTP 404 Not Found.
class NotFoundException extends ApiException {
  const NotFoundException({
    super.message = 'The requested resource was not found.',
    super.statusCode = 404,
    super.data,
  });

  @override
  String toString() => 'NotFoundException: $message';
}
