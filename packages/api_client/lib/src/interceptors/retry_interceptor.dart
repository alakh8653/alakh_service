import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required this.dio,
    this.retries = 3,
    this.retryDelays = const [
      Duration(seconds: 1),
      Duration(seconds: 2),
      Duration(seconds: 4),
    ],
  });

  final Dio dio;
  final int retries;
  final List<Duration> retryDelays;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final extra = err.requestOptions.extra;
    final attempt = extra['retryCount'] as int? ?? 0;

    final shouldRetry = _shouldRetry(err) && attempt < retries;

    if (shouldRetry) {
      final delay = attempt < retryDelays.length
          ? retryDelays[attempt]
          : retryDelays.last;

      await Future<void>.delayed(delay);

      err.requestOptions.extra['retryCount'] = attempt + 1;

      try {
        final response = await dio.fetch<dynamic>(err.requestOptions);
        handler.resolve(response);
        return;
      } catch (e) {
        // Fall through to propagate error
      }
    }

    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      return true;
    }
    final statusCode = err.response?.statusCode ?? 0;
    return statusCode >= 500;
  }
}
