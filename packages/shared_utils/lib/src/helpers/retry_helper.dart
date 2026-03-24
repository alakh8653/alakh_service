/// Provides a static helper that retries an async operation using
/// exponential backoff.
class RetryHelper {
  RetryHelper._();

  /// Retries [fn] up to [maxAttempts] times with exponential backoff.
  ///
  /// Parameters:
  /// - [maxAttempts] – total number of attempts (default: `3`).
  /// - [initialDelay] – wait time before the second attempt (default: `1s`).
  /// - [backoffFactor] – multiplier applied to the delay after each failure
  ///   (default: `2.0`).
  /// - [retryIf] – optional predicate; when provided, only retries if it
  ///   returns `true` for the thrown [Exception].
  ///
  /// Returns the result of [fn] on success.
  /// Re-throws the last exception after all attempts are exhausted.
  static Future<T> retry<T>(
    Future<T> Function() fn, {
    int maxAttempts = 3,
    Duration initialDelay = const Duration(seconds: 1),
    double backoffFactor = 2.0,
    bool Function(Exception)? retryIf,
  }) async {
    assert(maxAttempts >= 1, 'maxAttempts must be at least 1');
    var delay = initialDelay;
    Exception? lastException;

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        return await fn();
      } on Exception catch (e) {
        lastException = e;
        if (retryIf != null && !retryIf(e)) rethrow;
        if (attempt < maxAttempts) {
          await Future<void>.delayed(delay);
          delay = Duration(
            microseconds: (delay.inMicroseconds * backoffFactor).round(),
          );
        }
      }
    }
    throw lastException!;
  }
}
