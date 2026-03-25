import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';

/// Contract for local (cache) booking data operations.
abstract class BookingLocalDataSource {
  Future<void> cacheBookings(List<BookingModel> bookings);
  Future<List<BookingModel>> getCachedBookings();
  Future<void> cacheBookingDetails(BookingModel booking);
  Future<BookingModel?> getCachedBookingDetails(String bookingId);
  Future<void> clearBookingCache();
}

/// SharedPreferences implementation of [BookingLocalDataSource].
class BookingLocalDataSourceImpl implements BookingLocalDataSource {
  final SharedPreferences _prefs;

  static const String _bookingsKey = 'cached_bookings';
  static const String _bookingDetailPrefix = 'cached_booking_';

  const BookingLocalDataSourceImpl(this._prefs);

  @override
  Future<void> cacheBookings(List<BookingModel> bookings) async {
    final encoded = jsonEncode(bookings.map((b) => b.toJson()).toList());
    await _prefs.setString(_bookingsKey, encoded);
  }

  @override
  Future<List<BookingModel>> getCachedBookings() async {
    final raw = _prefs.getString(_bookingsKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => BookingModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> cacheBookingDetails(BookingModel booking) async {
    final encoded = jsonEncode(booking.toJson());
    await _prefs.setString('$_bookingDetailPrefix${booking.id}', encoded);
  }

  @override
  Future<BookingModel?> getCachedBookingDetails(String bookingId) async {
    final raw = _prefs.getString('$_bookingDetailPrefix$bookingId');
    if (raw == null) return null;
    return BookingModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> clearBookingCache() async {
    final keys = _prefs.getKeys().where(
          (k) => k == _bookingsKey || k.startsWith(_bookingDetailPrefix),
        );
    for (final key in keys) {
      await _prefs.remove(key);
    }
  }
}
