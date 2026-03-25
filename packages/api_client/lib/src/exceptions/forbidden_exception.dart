import 'api_exception.dart';

/// Thrown when the server responds with HTTP 403 Forbidden.
///
/// The client is authenticated but does not have permission to access the
/// requested resource.
class ForbiddenException extends ApiException {
  const ForbiddenException({
    super.message = 'You do not have permission to perform this action.',
    super.statusCode = 403,
    super.data,
  });

  @override
  String toString() => 'ForbiddenException: $message';
}
