import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/models.dart';

/// Contract for remote (API) booking data operations.
abstract class BookingRemoteDataSource {
  Future<BookingModel> createBooking(BookingRequestModel request);
  Future<BookingModel> cancelBooking(String bookingId, String reason);
  Future<BookingModel> rescheduleBooking(String bookingId, String newTimeSlotId, String? reason);
  Future<List<TimeSlotModel>> getAvailableSlots(String shopId, String serviceId, DateTime date, String? staffId);
  Future<List<BookingModel>> getUserBookings(String userId);
  Future<BookingModel> getBookingDetails(String bookingId);
  Future<List<BookingModel>> getUpcomingBookings(String userId);
}

/// HTTP implementation of [BookingRemoteDataSource].
class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final http.Client _client;
  final String _baseUrl;

  const BookingRemoteDataSourceImpl({
    required http.Client client,
    required String baseUrl,
  })  : _client = client,
        _baseUrl = baseUrl;

  @override
  Future<BookingModel> createBooking(BookingRequestModel request) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/bookings'),
      headers: _jsonHeaders,
      body: jsonEncode(request.toJson()),
    );
    _assertSuccess(response, 'Failed to create booking');
    return BookingModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  @override
  Future<BookingModel> cancelBooking(String bookingId, String reason) async {
    final response = await _client.patch(
      Uri.parse('$_baseUrl/bookings/$bookingId/cancel'),
      headers: _jsonHeaders,
      body: jsonEncode({'reason': reason}),
    );
    _assertSuccess(response, 'Failed to cancel booking');
    return BookingModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  @override
  Future<BookingModel> rescheduleBooking(
      String bookingId, String newTimeSlotId, String? reason) async {
    final response = await _client.patch(
      Uri.parse('$_baseUrl/bookings/$bookingId/reschedule'),
      headers: _jsonHeaders,
      body: jsonEncode({
        'newTimeSlotId': newTimeSlotId,
        if (reason != null) 'reason': reason,
      }),
    );
    _assertSuccess(response, 'Failed to reschedule booking');
    return BookingModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  @override
  Future<List<TimeSlotModel>> getAvailableSlots(
      String shopId, String serviceId, DateTime date, String? staffId) async {
    final queryParams = <String, String>{
      'shopId': shopId,
      'serviceId': serviceId,
      'date': date.toIso8601String().substring(0, 10),
      if (staffId != null) 'staffId': staffId,
    };
    final response = await _client.get(
      Uri.parse('$_baseUrl/slots').replace(queryParameters: queryParams),
      headers: _jsonHeaders,
    );
    _assertSuccess(response, 'Failed to fetch available slots');
    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .map((e) => TimeSlotModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<BookingModel>> getUserBookings(String userId) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/bookings').replace(queryParameters: {'userId': userId}),
      headers: _jsonHeaders,
    );
    _assertSuccess(response, 'Failed to fetch user bookings');
    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .map((e) => BookingModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<BookingModel> getBookingDetails(String bookingId) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/bookings/$bookingId'),
      headers: _jsonHeaders,
    );
    _assertSuccess(response, 'Failed to fetch booking details');
    return BookingModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  @override
  Future<List<BookingModel>> getUpcomingBookings(String userId) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/bookings/upcoming')
          .replace(queryParameters: {'userId': userId}),
      headers: _jsonHeaders,
    );
    _assertSuccess(response, 'Failed to fetch upcoming bookings');
    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .map((e) => BookingModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static const Map<String, String> _jsonHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  void _assertSuccess(http.Response response, String errorMessage) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('$errorMessage (HTTP ${response.statusCode})');
    }
  }
}
