import 'package:shared_models/shared_models.dart';
import 'package:test/test.dart';

void main() {
  group('PaginatedResponse<String>', () {
    final json = <String, dynamic>{
      'items': ['alpha', 'beta', 'gamma'],
      'total': 10,
      'page': 1,
      'perPage': 3,
      'hasMore': true,
    };

    test('fromJson deserializes all fields correctly', () {
      final response = PaginatedResponse.fromJson(json, (e) => e as String);

      expect(response.items, ['alpha', 'beta', 'gamma']);
      expect(response.total, 10);
      expect(response.page, 1);
      expect(response.perPage, 3);
      expect(response.hasMore, isTrue);
    });

    test('toJson serializes all fields correctly', () {
      final response = PaginatedResponse.fromJson(json, (e) => e as String);
      final serialized = response.toJson((item) => item);

      expect(serialized['items'], ['alpha', 'beta', 'gamma']);
      expect(serialized['total'], 10);
      expect(serialized['page'], 1);
      expect(serialized['perPage'], 3);
      expect(serialized['hasMore'], isTrue);
    });

    test('round-trip fromJson → toJson → fromJson produces identical object', () {
      final original = PaginatedResponse.fromJson(json, (e) => e as String);
      final roundTripped = PaginatedResponse.fromJson(
          original.toJson((item) => item), (e) => e as String);

      expect(roundTripped, equals(original));
    });

    test('copyWith overrides specified fields only', () {
      final original = PaginatedResponse.fromJson(json, (e) => e as String);
      final updated = original.copyWith(page: 2, hasMore: false);

      expect(updated.page, 2);
      expect(updated.hasMore, isFalse);
      expect(updated.items, original.items);
      expect(updated.total, original.total);
      expect(updated.perPage, original.perPage);
    });

    test('equality holds for identical instances', () {
      final a = PaginatedResponse.fromJson(json, (e) => e as String);
      final b = PaginatedResponse.fromJson(json, (e) => e as String);

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('last page has hasMore false', () {
      final lastPage = PaginatedResponse<String>(
        items: const ['delta'],
        total: 4,
        page: 2,
        perPage: 3,
        hasMore: false,
      );

      expect(lastPage.hasMore, isFalse);
      expect(lastPage.items.length, 1);
    });

    test('empty response', () {
      final empty = PaginatedResponse<String>(
        items: const [],
        total: 0,
        page: 1,
        perPage: 10,
        hasMore: false,
      );

      expect(empty.items, isEmpty);
      expect(empty.total, 0);
    });
  });
}
