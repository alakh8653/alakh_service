import 'package:api_client/api_client.dart';
import 'package:test/test.dart';

void main() {
  group('ApiException', () {
    test('is an Exception', () {
      const e = ApiException(message: 'oops');
      expect(e, isA<Exception>());
    });

    test('toString includes message', () {
      const e = ApiException(message: 'something went wrong');
      expect(e.toString(), contains('something went wrong'));
    });

    test('toString includes status code when present', () {
      const e = ApiException(message: 'bad request', statusCode: 400);
      expect(e.toString(), contains('400'));
    });
  });

  group('Exception hierarchy', () {
    test('NetworkException is-a ApiException', () {
      expect(const NetworkException(), isA<ApiException>());
    });

    test('ServerException is-a ApiException', () {
      expect(const ServerException(), isA<ApiException>());
    });

    test('UnauthorizedException is-a ApiException with statusCode 401', () {
      const e = UnauthorizedException();
      expect(e, isA<ApiException>());
      expect(e.statusCode, equals(401));
    });

    test('ForbiddenException is-a ApiException with statusCode 403', () {
      const e = ForbiddenException();
      expect(e, isA<ApiException>());
      expect(e.statusCode, equals(403));
    });

    test('NotFoundException is-a ApiException with statusCode 404', () {
      const e = NotFoundException();
      expect(e, isA<ApiException>());
      expect(e.statusCode, equals(404));
    });

    test('ValidationException is-a ApiException with statusCode 422', () {
      const e = ValidationException();
      expect(e, isA<ApiException>());
      expect(e.statusCode, equals(422));
    });

    test('ValidationException.errorsFor returns messages for known field', () {
      const e = ValidationException(
        fieldErrors: {
          'email': ['must be a valid email', 'is required'],
        },
      );
      expect(e.errorsFor('email'), containsAll(['must be a valid email', 'is required']));
    });

    test('ValidationException.errorsFor returns empty list for unknown field', () {
      const e = ValidationException();
      expect(e.errorsFor('nonexistent'), isEmpty);
    });

    test('RateLimitException is-a ApiException with statusCode 429', () {
      const e = RateLimitException();
      expect(e, isA<ApiException>());
      expect(e.statusCode, equals(429));
    });

    test('RateLimitException.retryAfter is null by default', () {
      const e = RateLimitException();
      expect(e.retryAfter, isNull);
    });

    test('RateLimitException.toString includes retry hint when retryAfter set', () {
      const e = RateLimitException(retryAfter: Duration(seconds: 30));
      expect(e.toString(), contains('30'));
    });

    test('RequestTimeoutException is-a ApiException', () {
      expect(const RequestTimeoutException(), isA<ApiException>());
    });
  });

  group('ApiErrorResponse', () {
    test('fromJson parses all fields', () {
      final json = {
        'code': 'VALIDATION_ERROR',
        'message': 'Invalid input',
        'fieldErrors': {
          'name': ['too short'],
        },
        'statusCode': 422,
        'timestamp': '2024-01-01T00:00:00Z',
      };
      final response = ApiErrorResponse.fromJson(json);

      expect(response.code, equals('VALIDATION_ERROR'));
      expect(response.message, equals('Invalid input'));
      expect(response.fieldErrors?['name'], contains('too short'));
      expect(response.statusCode, equals(422));
      expect(response.timestamp, equals('2024-01-01T00:00:00Z'));
    });

    test('fromJson uses defaults for missing fields', () {
      final response = ApiErrorResponse.fromJson({});
      expect(response.code, equals('UNKNOWN_ERROR'));
      expect(response.message, isNotEmpty);
    });

    test('toJson round-trips correctly', () {
      const original = ApiErrorResponse(
        code: 'NOT_FOUND',
        message: 'Resource missing',
        statusCode: 404,
      );
      final json = original.toJson();
      final restored = ApiErrorResponse.fromJson(json);

      expect(restored.code, equals(original.code));
      expect(restored.message, equals(original.message));
      expect(restored.statusCode, equals(original.statusCode));
    });
  });

  group('PaginationParams', () {
    test('default values', () {
      const p = PaginationParams();
      expect(p.page, equals(1));
      expect(p.perPage, equals(20));
      expect(p.sortOrder, equals('asc'));
      expect(p.sortBy, isNull);
    });

    test('toQueryParams includes expected keys', () {
      const p = PaginationParams(page: 2, perPage: 10, sortBy: 'name', sortOrder: 'desc');
      final params = p.toQueryParams();

      expect(params['page'], equals(2));
      expect(params['per_page'], equals(10));
      expect(params['sort_by'], equals('name'));
      expect(params['sort_order'], equals('desc'));
    });

    test('toQueryParams omits sort_by when null', () {
      const p = PaginationParams();
      expect(p.toQueryParams().containsKey('sort_by'), isFalse);
    });

    test('nextPage increments page by 1', () {
      const p = PaginationParams(page: 3);
      expect(p.nextPage().page, equals(4));
    });

    test('previousPage decrements page by 1', () {
      const p = PaginationParams(page: 3);
      expect(p.previousPage().page, equals(2));
    });

    test('previousPage clamps to page 1', () {
      const p = PaginationParams(page: 1);
      expect(p.previousPage().page, equals(1));
    });
  });
}
