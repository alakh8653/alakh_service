import 'dart:async';

import 'package:auth_module/auth_module.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockAuthStorage extends Mock implements AuthStorage {}

class FakeAuthToken extends Fake implements AuthToken {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

AuthToken _makeToken({String refreshToken = 'refresh-token'}) => AuthToken(
      accessToken: 'new-access-token',
      refreshToken: refreshToken,
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    );

AuthToken _storedToken({String refreshToken = 'refresh-token'}) => AuthToken(
      accessToken: 'old-access-token',
      refreshToken: refreshToken,
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockAuthStorage storage;

  setUpAll(() {
    registerFallbackValue(FakeAuthToken());
  });

  setUp(() {
    storage = MockAuthStorage();
  });

  // -------------------------------------------------------------------------
  // Successful refresh
  // -------------------------------------------------------------------------

  group('successful refresh', () {
    test('calls refreshFn with the stored refresh token and persists result',
        () async {
      final stored = _storedToken();
      when(() => storage.getToken()).thenAnswer((_) async => stored);
      when(() => storage.saveToken(any())).thenAnswer((_) async {});

      AuthToken? receivedRefreshToken;
      final refresher = TokenRefresher(
        refreshFn: (rt) async {
          receivedRefreshToken = AuthToken(
            accessToken: 'x',
            refreshToken: rt,
            expiresAt: DateTime.now(),
          );
          return _makeToken(refreshToken: rt);
        },
        storage: storage,
      );

      final result = await refresher.refresh();

      expect(result, isNotNull);
      expect(result!.accessToken, 'new-access-token');
      expect(receivedRefreshToken?.refreshToken, stored.refreshToken);
      verify(() => storage.saveToken(any())).called(1);
    });

    test('returns null and does not call saveToken when no token is stored',
        () async {
      when(() => storage.getToken()).thenAnswer((_) async => null);

      final refresher = TokenRefresher(
        refreshFn: (_) async => _makeToken(),
        storage: storage,
      );

      final result = await refresher.refresh();

      expect(result, isNull);
      verifyNever(() => storage.saveToken(any()));
    });

    test('returns null when refreshFn returns null', () async {
      when(() => storage.getToken()).thenAnswer((_) async => _storedToken());

      final refresher = TokenRefresher(
        refreshFn: (_) async => null,
        storage: storage,
      );

      final result = await refresher.refresh();

      expect(result, isNull);
      verifyNever(() => storage.saveToken(any()));
    });
  });

  // -------------------------------------------------------------------------
  // Failed refresh
  // -------------------------------------------------------------------------

  group('failed refresh', () {
    test('propagates exception from refreshFn', () async {
      when(() => storage.getToken()).thenAnswer((_) async => _storedToken());

      final refresher = TokenRefresher(
        refreshFn: (_) async => throw Exception('network error'),
        storage: storage,
      );

      await expectLater(refresher.refresh, throwsException);
    });

    test('resets lock after failure so a subsequent call can succeed', () async {
      when(() => storage.getToken()).thenAnswer((_) async => _storedToken());
      when(() => storage.saveToken(any())).thenAnswer((_) async {});

      var callCount = 0;
      final refresher = TokenRefresher(
        refreshFn: (_) async {
          callCount++;
          if (callCount == 1) throw Exception('first call fails');
          return _makeToken();
        },
        storage: storage,
      );

      // First call throws.
      await expectLater(refresher.refresh, throwsException);

      // Second call should succeed.
      final result = await refresher.refresh();
      expect(result, isNotNull);
    });
  });

  // -------------------------------------------------------------------------
  // Concurrent refresh lock
  // -------------------------------------------------------------------------

  group('concurrent refresh lock', () {
    test('only invokes refreshFn once when called concurrently', () async {
      when(() => storage.getToken()).thenAnswer((_) async => _storedToken());
      when(() => storage.saveToken(any())).thenAnswer((_) async {});

      var refreshFnCallCount = 0;
      final completerInsideFn = Completer<void>();

      final refresher = TokenRefresher(
        refreshFn: (_) async {
          refreshFnCallCount++;
          // Simulate a slow network call.
          await completerInsideFn.future;
          return _makeToken();
        },
        storage: storage,
      );

      // Fire three concurrent refresh requests.
      final futures = [
        refresher.refresh(),
        refresher.refresh(),
        refresher.refresh(),
      ];

      // Allow the network call to complete.
      completerInsideFn.complete();

      final results = await Future.wait(futures);

      // The refresh function should have been called exactly once.
      expect(refreshFnCallCount, 1);

      // All three callers should receive the same new token.
      for (final result in results) {
        expect(result?.accessToken, 'new-access-token');
      }
    });

    test('all concurrent waiters receive error when refreshFn throws', () async {
      when(() => storage.getToken()).thenAnswer((_) async => _storedToken());

      final completerInsideFn = Completer<void>();

      final refresher = TokenRefresher(
        refreshFn: (_) async {
          await completerInsideFn.future;
          throw Exception('refresh failed');
        },
        storage: storage,
      );

      final futures = [
        refresher.refresh(),
        refresher.refresh(),
      ];

      completerInsideFn.complete();

      // Both futures should throw.
      for (final f in futures) {
        await expectLater(f, throwsException);
      }
    });
  });
}
