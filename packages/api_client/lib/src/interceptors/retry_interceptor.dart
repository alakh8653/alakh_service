import 'package:dio/dio.dart';

/// Dio interceptor that retries failed requests with exponential back-off.
///
/// Retries are triggered when:
/// - The error type is [DioExceptionType.connectionError] (network issue), or
/// - The response status code is in [retryStatusCodes] (e.g. 429, 503).
///
/// The delay between attempts grows according to:
/// `retryDelay * (backoffFactor ^ attemptIndex)`.
class RetryInterceptor extends Interceptor {
  /// Maximum number of retry attempts (not counting the initial request).
  final int maxRetries;

  /// Base delay before the first retry.
  final Duration retryDelay;

  /// Multiplier applied to [retryDelay] after each successive failure.
  final double backoffFactor;

  /// HTTP status codes that should trigger a retry.
  final List<int> retryStatusCodes;

  /// Key used to track the retry count in [RequestOptions.extra].
  static const _retryCountKey = '_retryCount';

  /// Creates a [RetryInterceptor].
  const RetryInterceptor({
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
    this.backoffFactor = 2.0,
    this.retryStatusCodes = const [429, 503],
  });

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (!_shouldRetry(err)) {
      handler.next(err);
      return;
    }

    final attempt = (err.requestOptions.extra[_retryCountKey] as int?) ?? 0;
    if (attempt >= maxRetries) {
      handler.next(err);
      return;
    }

    final delay = _computeDelay(attempt);
    await Future<void>.delayed(delay);

    final options = err.requestOptions
      ..extra[_retryCountKey] = attempt + 1;

    try {
      final response = await err.requestOptions.extra['_dio'] != null
          ? (err.requestOptions.extra['_dio'] as Dio).fetch(options)
          : Dio().fetch(options);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  bool _shouldRetry(DioException e) {
    if (e.type == DioExceptionType.connectionError) return true;
    final statusCode = e.response?.statusCode;
    return statusCode != null && retryStatusCodes.contains(statusCode);
  }

  Duration _computeDelay(int attempt) {
    final multiplier = backoffFactor == 1.0
        ? 1.0
        : _pow(backoffFactor, attempt);
    return Duration(
      milliseconds: (retryDelay.inMilliseconds * multiplier).round(),
    );
  }

  double _pow(double base, int exponent) {
    double result = 1.0;
    for (int i = 0; i < exponent; i++) {
      result *= base;
    }
    return result;
  }
}

/// Extension on [Dio] that registers itself so [RetryInterceptor] can
/// re-issue requests through the same instance (including other interceptors).
extension RetryDioExtension on Dio {
  /// Adds a [RetryInterceptor] that is wired back to this [Dio] instance.
  void addRetryInterceptor({
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 1),
    double backoffFactor = 2.0,
    List<int> retryStatusCodes = const [429, 503],
  }) {
    interceptors.add(
      _BoundRetryInterceptor(
        dio: this,
        maxRetries: maxRetries,
        retryDelay: retryDelay,
        backoffFactor: backoffFactor,
        retryStatusCodes: retryStatusCodes,
      ),
    );
  }
}

/// Internal retry interceptor variant that holds a reference to the [Dio]
/// instance so retries run through all registered interceptors.
class _BoundRetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final Duration retryDelay;
  final double backoffFactor;
  final List<int> retryStatusCodes;

  static const _retryCountKey = '_retryCount';

  _BoundRetryInterceptor({
    required this.dio,
    required this.maxRetries,
    required this.retryDelay,
    required this.backoffFactor,
    required this.retryStatusCodes,
  });

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (!_shouldRetry(err)) {
      handler.next(err);
      return;
    }

    final attempt = (err.requestOptions.extra[_retryCountKey] as int?) ?? 0;
    if (attempt >= maxRetries) {
      handler.next(err);
      return;
    }

    final delay = _computeDelay(attempt);
    await Future<void>.delayed(delay);

    err.requestOptions.extra[_retryCountKey] = attempt + 1;

    try {
      final response = await dio.fetch(err.requestOptions);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  bool _shouldRetry(DioException e) {
    if (e.type == DioExceptionType.connectionError) return true;
    final statusCode = e.response?.statusCode;
    return statusCode != null && retryStatusCodes.contains(statusCode);
  }

  Duration _computeDelay(int attempt) {
    double multiplier = 1.0;
    for (int i = 0; i < attempt; i++) {
      multiplier *= backoffFactor;
    }
    return Duration(
      milliseconds: (retryDelay.inMilliseconds * multiplier).round(),
    );
  }
}
