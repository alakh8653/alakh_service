import 'api_exception.dart';

/// Thrown when a request exceeds the configured timeout duration.
///
/// Named [RequestTimeoutException] to avoid a naming conflict with
/// [dart:io]'s `TimeoutException`.
class RequestTimeoutException extends ApiException {
  const RequestTimeoutException({
    super.message = 'The request timed out. Please try again.',
    super.statusCode,
    super.data,
  });

  @override
  String toString() => 'RequestTimeoutException: $message';
}
