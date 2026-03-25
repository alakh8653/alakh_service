import 'package:shared_models/shared_models.dart';
import 'package:test/test.dart';

void main() {
  group('User', () {
    final createdAt = DateTime.utc(2024, 1, 15, 10, 30);

    final userJson = <String, dynamic>{
      'id': 'user-123',
      'name': 'Priya Sharma',
      'email': 'priya@example.com',
      'phone': '+919876543210',
      'avatar': 'https://example.com/avatar.png',
      'role': 'shopOwner',
      'isVerified': true,
      'createdAt': createdAt.toIso8601String(),
    };

    test('fromJson deserializes all fields correctly', () {
      final user = User.fromJson(userJson);

      expect(user.id, 'user-123');
      expect(user.name, 'Priya Sharma');
      expect(user.email, 'priya@example.com');
      expect(user.phone, '+919876543210');
      expect(user.avatar, 'https://example.com/avatar.png');
      expect(user.role, UserRole.shopOwner);
      expect(user.isVerified, isTrue);
      expect(user.createdAt, createdAt);
    });

    test('toJson serializes all fields correctly', () {
      final user = User.fromJson(userJson);
      final json = user.toJson();

      expect(json['id'], 'user-123');
      expect(json['name'], 'Priya Sharma');
      expect(json['email'], 'priya@example.com');
      expect(json['phone'], '+919876543210');
      expect(json['avatar'], 'https://example.com/avatar.png');
      expect(json['role'], 'shopOwner');
      expect(json['isVerified'], isTrue);
      expect(json['createdAt'], createdAt.toIso8601String());
    });

    test('fromJson → toJson round-trip produces identical JSON', () {
      final user = User.fromJson(userJson);
      final roundTripped = User.fromJson(user.toJson());

      expect(roundTripped, equals(user));
    });

    test('optional fields are omitted from toJson when null', () {
      final user = User(
        id: 'u1',
        name: 'Arjun',
        email: 'arjun@example.com',
        role: UserRole.customer,
        isVerified: false,
        createdAt: createdAt,
      );
      final json = user.toJson();

      expect(json.containsKey('phone'), isFalse);
      expect(json.containsKey('avatar'), isFalse);
    });

    test('copyWith overrides only specified fields', () {
      final original = User.fromJson(userJson);
      final updated = original.copyWith(name: 'Priya S.', isVerified: false);

      expect(updated.name, 'Priya S.');
      expect(updated.isVerified, isFalse);
      // unchanged fields
      expect(updated.id, original.id);
      expect(updated.email, original.email);
      expect(updated.role, original.role);
    });

    test('equality holds for identical instances', () {
      final a = User.fromJson(userJson);
      final b = User.fromJson(userJson);

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('UserRole.fromJson falls back to customer for unknown values', () {
      expect(UserRole.fromJson('unknown'), UserRole.customer);
    });

    test('UserRole round-trip', () {
      for (final role in UserRole.values) {
        expect(UserRole.fromJson(role.toJson()), role);
      }
    });
  });
}
