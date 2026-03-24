import 'package:auth_module/auth_module.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockAuthStorage extends Mock implements AuthStorage {}

class MockTokenRefresher extends Mock implements TokenRefresher {}

class FakeAuthToken extends Fake implements AuthToken {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

AuthToken _makeToken({bool expired = false, bool aboutToExpire = false}) {
  final DateTime expiresAt;
  if (expired) {
    expiresAt = DateTime.now().subtract(const Duration(hours: 1));
  } else if (aboutToExpire) {
    expiresAt = DateTime.now().add(const Duration(minutes: 2));
  } else {
    expiresAt = DateTime.now().add(const Duration(hours: 1));
  }
  return AuthToken(
    accessToken: 'access-token',
    refreshToken: 'refresh-token',
    expiresAt: expiresAt,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockAuthStorage storage;
  late MockTokenRefresher refresher;
  late AuthManager manager;

  setUpAll(() {
    registerFallbackValue(FakeAuthToken());
  });

  setUp(() {
    storage = MockAuthStorage();
    refresher = MockTokenRefresher();
    manager = AuthManager(storage: storage, refresher: refresher);
  });

  tearDown(() => manager.dispose());

  // -------------------------------------------------------------------------
  // initialize()
  // -------------------------------------------------------------------------

  group('initialize()', () {
    test('emits Unauthenticated when storage is empty', () async {
      when(() => storage.getToken()).thenAnswer((_) async => null);

      await expectLater(
        manager.stateStream,
        emitsInOrder([isA<AuthLoading>(), isA<Unauthenticated>()]),
      );
      await manager.initialize();
    });

    test('emits Authenticated when a valid token is stored', () async {
      final token = _makeToken();
      when(() => storage.getToken()).thenAnswer((_) async => token);

      await expectLater(
        manager.stateStream,
        emitsInOrder([isA<AuthLoading>(), isA<Authenticated>()]),
      );
      await manager.initialize();

      expect(manager.isAuthenticated, isTrue);
    });

    test('attempts refresh and emits Unauthenticated when token is expired '
        'and refresh fails', () async {
      final expiredToken = _makeToken(expired: true);
      when(() => storage.getToken()).thenAnswer((_) async => expiredToken);
      when(() => refresher.refresh()).thenAnswer((_) async => null);
      when(() => storage.deleteToken()).thenAnswer((_) async {});

      final states = <AuthState>[];
      manager.stateStream.listen(states.add);

      await manager.initialize();

      expect(states.whereType<Unauthenticated>(), isNotEmpty);
      expect(manager.isAuthenticated, isFalse);
    });

    test('emits Authenticated when expired token is successfully refreshed',
        () async {
      final expiredToken = _makeToken(expired: true);
      final newToken = _makeToken();
      when(() => storage.getToken())
          .thenAnswer((_) async => expiredToken);
      when(() => refresher.refresh()).thenAnswer((_) async => newToken);
      when(() => storage.saveToken(any())).thenAnswer((_) async {});

      final states = <AuthState>[];
      manager.stateStream.listen(states.add);

      await manager.initialize();

      expect(states.whereType<Authenticated>(), isNotEmpty);
    });
  });

  // -------------------------------------------------------------------------
  // loginWithToken()
  // -------------------------------------------------------------------------

  group('loginWithToken()', () {
    test('saves token and emits Authenticated', () async {
      final token = _makeToken();
      when(() => storage.saveToken(any())).thenAnswer((_) async {});

      final states = <AuthState>[];
      manager.stateStream.listen(states.add);

      await manager.loginWithToken(
        token,
        userId: 'user-1',
        email: 'test@example.com',
      );

      verify(() => storage.saveToken(any())).called(1);

      final authenticated = states.whereType<Authenticated>().first;
      expect(authenticated.userId, 'user-1');
      expect(authenticated.email, 'test@example.com');
      expect(authenticated.token, token);
    });

    test('emits AuthLoading before Authenticated', () async {
      final token = _makeToken();
      when(() => storage.saveToken(any())).thenAnswer((_) async {});

      await expectLater(
        manager.stateStream,
        emitsInOrder([isA<AuthLoading>(), isA<Authenticated>()]),
      );
      await manager.loginWithToken(token, userId: 'user-1');
    });
  });

  // -------------------------------------------------------------------------
  // logout()
  // -------------------------------------------------------------------------

  group('logout()', () {
    test('deletes token and emits Unauthenticated', () async {
      // First log in.
      when(() => storage.saveToken(any())).thenAnswer((_) async {});
      await manager.loginWithToken(_makeToken(), userId: 'user-1');

      when(() => storage.deleteToken()).thenAnswer((_) async {});

      final states = <AuthState>[];
      manager.stateStream.listen(states.add);

      await manager.logout();

      verify(() => storage.deleteToken()).called(1);
      expect(states.last, isA<Unauthenticated>());
      expect(manager.isAuthenticated, isFalse);
    });

    test('emits Unauthenticated even when deleteToken throws', () async {
      when(() => storage.saveToken(any())).thenAnswer((_) async {});
      await manager.loginWithToken(_makeToken(), userId: 'user-1');

      when(() => storage.deleteToken()).thenThrow(Exception('disk error'));

      final states = <AuthState>[];
      manager.stateStream.listen(states.add);

      await manager.logout();

      expect(states.last, isA<Unauthenticated>());
    });
  });

  // -------------------------------------------------------------------------
  // getValidAccessToken()
  // -------------------------------------------------------------------------

  group('getValidAccessToken()', () {
    test('returns null when not authenticated', () async {
      expect(await manager.getValidAccessToken(), isNull);
    });

    test('returns access token when token is fresh', () async {
      when(() => storage.saveToken(any())).thenAnswer((_) async {});
      final token = _makeToken();
      await manager.loginWithToken(token, userId: 'user-1');

      final result = await manager.getValidAccessToken();
      expect(result, 'access-token');
    });

    test('refreshes and returns new access token when token is about to expire',
        () async {
      when(() => storage.saveToken(any())).thenAnswer((_) async {});
      final token = _makeToken(aboutToExpire: true);
      await manager.loginWithToken(token, userId: 'user-1');

      final newToken = _makeToken();
      when(() => refresher.refresh()).thenAnswer((_) async => newToken);

      final result = await manager.getValidAccessToken();
      expect(result, 'access-token');
    });
  });
}
