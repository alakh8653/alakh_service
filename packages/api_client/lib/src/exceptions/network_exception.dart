import 'api_exception.dart';

/// Thrown when the device has no internet connection or the server is
/// unreachable (i.e. a transport-level failure rather than an HTTP error).
class NetworkException extends ApiException {
  const NetworkException({
    super.message = 'No internet connection or the server could not be reached.',
    super.statusCode,
    super.data,
  });

  @override
  String toString() => 'NetworkException: $message';
}
