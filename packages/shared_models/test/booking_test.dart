import 'package:shared_models/shared_models.dart';
import 'package:test/test.dart';

void main() {
  group('BookingStatus', () {
    test('toJson returns the enum name', () {
      expect(BookingStatus.inProgress.toJson(), 'inProgress');
      expect(BookingStatus.cancelled.toJson(), 'cancelled');
    });

    test('fromJson parses all valid values', () {
      for (final status in BookingStatus.values) {
        expect(BookingStatus.fromJson(status.name), status);
      }
    });

    test('fromJson falls back to pending for unknown values', () {
      expect(BookingStatus.fromJson('gibberish'), BookingStatus.pending);
    });
  });

  group('Booking', () {
    final dateTime = DateTime.utc(2024, 3, 20, 14, 0);

    final bookingJson = <String, dynamic>{
      'id': 'booking-abc',
      'userId': 'user-123',
      'shopId': 'shop-456',
      'serviceId': 'svc-789',
      'staffId': 'staff-001',
      'dateTime': dateTime.toIso8601String(),
      'durationMinutes': 60,
      'status': 'confirmed',
      'totalPrice': 499.0,
      'notes': 'Please use fragrance-free products.',
    };

    test('fromJson deserializes all fields correctly', () {
      final booking = Booking.fromJson(bookingJson);

      expect(booking.id, 'booking-abc');
      expect(booking.userId, 'user-123');
      expect(booking.shopId, 'shop-456');
      expect(booking.serviceId, 'svc-789');
      expect(booking.staffId, 'staff-001');
      expect(booking.dateTime, dateTime);
      expect(booking.durationMinutes, 60);
      expect(booking.status, BookingStatus.confirmed);
      expect(booking.totalPrice, 499.0);
      expect(booking.notes, 'Please use fragrance-free products.');
    });

    test('toJson serializes all fields correctly', () {
      final booking = Booking.fromJson(bookingJson);
      final json = booking.toJson();

      expect(json['id'], 'booking-abc');
      expect(json['status'], 'confirmed');
      expect(json['totalPrice'], 499.0);
      expect(json['durationMinutes'], 60);
      expect(json['dateTime'], dateTime.toIso8601String());
    });

    test('fromJson → toJson round-trip produces identical object', () {
      final booking = Booking.fromJson(bookingJson);
      final roundTripped = Booking.fromJson(booking.toJson());

      expect(roundTripped, equals(booking));
    });

    test('optional staffId and notes are omitted from toJson when null', () {
      final booking = Booking(
        id: 'b1',
        userId: 'u1',
        shopId: 's1',
        serviceId: 'sv1',
        dateTime: dateTime,
        durationMinutes: 30,
        status: BookingStatus.pending,
        totalPrice: 199.0,
      );
      final json = booking.toJson();

      expect(json.containsKey('staffId'), isFalse);
      expect(json.containsKey('notes'), isFalse);
    });

    test('copyWith updates status and totalPrice', () {
      final booking = Booking.fromJson(bookingJson);
      final updated = booking.copyWith(
        status: BookingStatus.completed,
        totalPrice: 550.0,
      );

      expect(updated.status, BookingStatus.completed);
      expect(updated.totalPrice, 550.0);
      expect(updated.id, booking.id);
      expect(updated.durationMinutes, booking.durationMinutes);
    });

    test('equality holds for identical instances', () {
      final a = Booking.fromJson(bookingJson);
      final b = Booking.fromJson(bookingJson);

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });
  });
}
