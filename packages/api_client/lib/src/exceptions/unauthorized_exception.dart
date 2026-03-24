import 'api_exception.dart';

/// Thrown when the server responds with HTTP 401 Unauthorized.
///
/// Typically indicates that the request lacks valid authentication credentials
/// or the access token has expired.
class UnauthorizedException extends ApiException {
  const UnauthorizedException({
    super.message = 'Authentication required.',
    super.statusCode = 401,
    super.data,
  });

  @override
  String toString() => 'UnauthorizedException: $message';
}
