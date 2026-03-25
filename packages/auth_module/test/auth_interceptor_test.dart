import 'package:auth_module/auth_module.dart';
import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockAuthManager extends Mock implements AuthManager {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

RequestOptions _opts(String path, {Map<String, dynamic>? extra}) =>
    RequestOptions(
      path: path,
      extra: extra ?? {},
    );

DioException _dioError(
  RequestOptions opts,
  int statusCode,
) =>
    DioException(
      requestOptions: opts,
      response: Response(requestOptions: opts, statusCode: statusCode),
      type: DioExceptionType.badResponse,
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockAuthManager authManager;
  late AuthDioInterceptor interceptor;

  setUp(() {
    authManager = MockAuthManager();
    interceptor = AuthDioInterceptor(authManager);
  });

  // -------------------------------------------------------------------------
  // onRequest — token injection
  // -------------------------------------------------------------------------

  group('onRequest()', () {
    test('injects Authorization header when token is available', () async {
      when(() => authManager.getValidAccessToken())
          .thenAnswer((_) async => 'valid-access-token');

      final opts = _opts('/api/profile');
      final handler = _CapturingRequestHandler();

      await interceptor.onRequest(opts, handler);

      expect(opts.headers['Authorization'], 'Bearer valid-access-token');
      expect(handler.nexted, isTrue);
    });

    test('does not inject header when token is null', () async {
      when(() => authManager.getValidAccessToken())
          .thenAnswer((_) async => null);

      final opts = _opts('/api/profile');
      final handler = _CapturingRequestHandler();

      await interceptor.onRequest(opts, handler);

      expect(opts.headers.containsKey('Authorization'), isFalse);
      expect(handler.nexted, isTrue);
    });

    test('skips auth injection when skipAuth extra is true', () async {
      final opts = _opts('/auth/login', extra: {'skipAuth': true});
      final handler = _CapturingRequestHandler();

      await interceptor.onRequest(opts, handler);

      verifyNever(() => authManager.getValidAccessToken());
      expect(opts.headers.containsKey('Authorization'), isFalse);
      expect(handler.nexted, isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // onError — 401 handling
  // -------------------------------------------------------------------------

  group('onError() 401 handling', () {
    test('passes non-401 errors through without refresh', () async {
      when(() => authManager.refreshToken()).thenAnswer((_) async => false);

      final opts = _opts('/api/resource');
      final err = _dioError(opts, 500);
      final handler = _CapturingErrorHandler();

      await interceptor.onError(err, handler);

      verifyNever(() => authManager.refreshToken());
      expect(handler.nexted, isTrue);
      expect(handler.passedError, err);
    });

    test('calls logout and passes error through when refresh fails', () async {
      when(() => authManager.refreshToken()).thenAnswer((_) async => false);
      when(() => authManager.logout()).thenAnswer((_) async {});

      final opts = _opts('/api/resource');
      final err = _dioError(opts, 401);
      final handler = _CapturingErrorHandler();

      await interceptor.onError(err, handler);

      verify(() => authManager.refreshToken()).called(1);
      verify(() => authManager.logout()).called(1);
      expect(handler.nexted, isTrue);
    });
  });
}

// ---------------------------------------------------------------------------
// Capturing handler helpers (avoid using real Dio handlers in unit tests)
// ---------------------------------------------------------------------------

class _CapturingRequestHandler extends RequestInterceptorHandler {
  bool nexted = false;

  @override
  void next(RequestOptions requestOptions) {
    nexted = true;
  }
}

class _CapturingErrorHandler extends ErrorInterceptorHandler {
  bool nexted = false;
  DioException? passedError;

  @override
  void next(DioException err) {
    nexted = true;
    passedError = err;
  }
}
