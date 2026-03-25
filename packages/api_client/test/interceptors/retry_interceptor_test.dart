import 'package:api_client/api_client.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

void main() {
  group('RetryInterceptor', () {
    test('default values are sensible', () {
      const interceptor = RetryInterceptor();
      expect(interceptor.maxRetries, equals(3));
      expect(interceptor.retryDelay, equals(const Duration(seconds: 1)));
      expect(interceptor.backoffFactor, equals(2.0));
      expect(interceptor.retryStatusCodes, containsAll([429, 503]));
    });

    test('accepts custom configuration', () {
      const interceptor = RetryInterceptor(
        maxRetries: 5,
        retryDelay: Duration(milliseconds: 500),
        backoffFactor: 1.5,
        retryStatusCodes: [429, 503, 502],
      );
      expect(interceptor.maxRetries, equals(5));
      expect(interceptor.retryDelay, equals(const Duration(milliseconds: 500)));
      expect(interceptor.backoffFactor, equals(1.5));
      expect(interceptor.retryStatusCodes, containsAll([429, 503, 502]));
    });

    group('error forwarding when retry is not applicable', () {
      test('forwards non-retryable errors immediately', () async {
        const interceptor = RetryInterceptor(maxRetries: 3);

        final error = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.cancel,
        );

        DioException? forwarded;
        final handler = _CapturingErrorHandler(onNext: (e) => forwarded = e);

        await interceptor.onError(error, handler);

        expect(forwarded, equals(error));
      });

      test('forwards errors once maxRetries is exhausted', () async {
        const interceptor = RetryInterceptor(maxRetries: 0);

        final requestOptions = RequestOptions(path: '/test');
        requestOptions.extra['_retryCount'] = 0;

        final error = DioException(
          requestOptions: requestOptions,
          type: DioExceptionType.connectionError,
        );

        DioException? forwarded;
        final handler = _CapturingErrorHandler(onNext: (e) => forwarded = e);

        await interceptor.onError(error, handler);

        expect(forwarded, equals(error));
      });
    });
  });

  group('RetryDioExtension', () {
    test('addRetryInterceptor registers a bound interceptor on the Dio instance', () {
      final dio = Dio();
      expect(dio.interceptors.length, equals(0));
      dio.addRetryInterceptor(maxRetries: 2);
      expect(dio.interceptors.length, equals(1));
    });
  });
}

class _CapturingErrorHandler extends ErrorInterceptorHandler {
  final void Function(DioException) onNext;
  _CapturingErrorHandler({required this.onNext});

  @override
  void next(DioException err) => onNext(err);
}
