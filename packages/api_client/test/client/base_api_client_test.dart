import 'package:api_client/api_client.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

// Concrete implementation used only in tests.
class _TestApiClient extends BaseApiClient {
  _TestApiClient(super.config);
}

void main() {
  group('BaseApiClient', () {
    late ApiClientConfig config;
    late _TestApiClient client;

    setUp(() {
      config = const ApiClientConfig(
        baseUrl: 'https://api.example.com',
        connectTimeout: Duration(seconds: 5),
        receiveTimeout: Duration(seconds: 15),
        sendTimeout: Duration(seconds: 15),
        headers: {'X-App-Version': '1.0.0'},
      );
      client = _TestApiClient(config);
    });

    test('initialises Dio with correct baseUrl', () {
      expect(client.dio.options.baseUrl, equals('https://api.example.com'));
    });

    test('initialises Dio with correct connectTimeout', () {
      expect(
        client.dio.options.connectTimeout,
        equals(const Duration(seconds: 5)),
      );
    });

    test('initialises Dio with correct receiveTimeout', () {
      expect(
        client.dio.options.receiveTimeout,
        equals(const Duration(seconds: 15)),
      );
    });

    test('initialises Dio with correct sendTimeout', () {
      expect(
        client.dio.options.sendTimeout,
        equals(const Duration(seconds: 15)),
      );
    });

    test('merges custom headers with default Content-Type and Accept', () {
      final headers = client.dio.options.headers;
      expect(headers['Content-Type'], equals('application/json'));
      expect(headers['Accept'], equals('application/json'));
      expect(headers['X-App-Version'], equals('1.0.0'));
    });

    test('exposes the same config that was passed in', () {
      expect(client.config, equals(config));
    });

    group('ApiClientConfig.copyWith', () {
      test('returns a new instance with updated baseUrl', () {
        final updated = config.copyWith(baseUrl: 'https://other.example.com');
        expect(updated.baseUrl, equals('https://other.example.com'));
        expect(updated.connectTimeout, equals(config.connectTimeout));
      });

      test('preserves original when no overrides provided', () {
        final copy = config.copyWith();
        expect(copy, equals(config));
      });
    });

    group('ApiClientConfig equality', () {
      test('two configs with same values are equal', () {
        final a = ApiClientConfig(baseUrl: 'https://a.com');
        final b = ApiClientConfig(baseUrl: 'https://a.com');
        expect(a, equals(b));
      });

      test('configs with different baseUrl are not equal', () {
        final a = ApiClientConfig(baseUrl: 'https://a.com');
        final b = ApiClientConfig(baseUrl: 'https://b.com');
        expect(a, isNot(equals(b)));
      });
    });
  });
}
