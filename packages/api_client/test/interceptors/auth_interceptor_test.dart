import 'package:api_client/api_client.dart';
import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockTokenProvider extends Mock implements TokenProvider {}

void main() {
  group('AuthInterceptor', () {
    late MockTokenProvider tokenProvider;
    late AuthInterceptor interceptor;

    setUp(() {
      tokenProvider = MockTokenProvider();
      interceptor = AuthInterceptor(tokenProvider);
    });

    RequestOptions buildOptions() => RequestOptions(path: '/test');

    test('attaches Bearer token when getAccessToken returns a token', () async {
      when(() => tokenProvider.getAccessToken())
          .thenAnswer((_) async => 'my-access-token');

      final options = buildOptions();
      late RequestOptions passedOptions;
      final handler = _CapturingHandler(onNext: (o) => passedOptions = o);

      await interceptor.onRequest(options, handler);

      expect(passedOptions.headers['Authorization'], equals('Bearer my-access-token'));
    });

    test('does not attach Authorization header when token is null', () async {
      when(() => tokenProvider.getAccessToken()).thenAnswer((_) async => null);

      final options = buildOptions();
      late RequestOptions passedOptions;
      final handler = _CapturingHandler(onNext: (o) => passedOptions = o);

      await interceptor.onRequest(options, handler);

      expect(passedOptions.headers.containsKey('Authorization'), isFalse);
    });

    test('calls handler.next after processing', () async {
      when(() => tokenProvider.getAccessToken())
          .thenAnswer((_) async => 'token');

      bool nextCalled = false;
      final handler = _CapturingHandler(onNext: (_) => nextCalled = true);

      await interceptor.onRequest(buildOptions(), handler);

      expect(nextCalled, isTrue);
    });
  });
}

/// Simple [RequestInterceptorHandler] substitute that captures [next] calls.
class _CapturingHandler extends RequestInterceptorHandler {
  final void Function(RequestOptions) onNext;

  _CapturingHandler({required this.onNext});

  @override
  void next(RequestOptions requestOptions) => onNext(requestOptions);
}
