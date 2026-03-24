import 'api_exception.dart';

/// Thrown when the server responds with HTTP 429 Too Many Requests.
///
/// [retryAfter] contains the suggested wait time before the next request,
/// parsed from the `Retry-After` response header when available.
class RateLimitException extends ApiException {
  /// Suggested duration to wait before retrying, or `null` if not specified.
  final Duration? retryAfter;

  const RateLimitException({
    super.message = 'Too many requests. Please slow down.',
    super.statusCode = 429,
    super.data,
    this.retryAfter,
  });

  @override
  String toString() {
    final hint =
        retryAfter != null ? ' Retry after ${retryAfter!.inSeconds}s.' : '';
    return 'RateLimitException: $message$hint';
  }
}
