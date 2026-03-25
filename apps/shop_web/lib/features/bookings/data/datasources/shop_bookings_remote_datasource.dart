/// Remote data source for the bookings feature.
library;

import 'package:shop_web/core/errors/shop_exceptions.dart';
import 'package:shop_web/core/network/shop_api_client.dart';
import 'package:shop_web/core/network/shop_api_endpoints.dart';
import 'package:shop_web/features/bookings/data/models/booking_filter_model.dart';
import 'package:shop_web/features/bookings/data/models/shop_booking_model.dart';

/// Contract for all booking-related remote operations.
abstract class ShopBookingsRemoteDataSource {
  /// Returns a paginated list of bookings and the total matching count.
  Future<(List<ShopBookingModel>, int)> getBookings(
    BookingFilterModel filters,
  );

  /// Fetches a single booking by its [id].
  Future<ShopBookingModel> getBookingById(String id);

  /// Updates the status of booking [id] to [status].
  Future<ShopBookingModel> updateBookingStatus(String id, String status);

  /// Cancels booking [id] with the provided [reason].
  Future<ShopBookingModel> cancelBooking(String id, String reason);

  /// Returns bookings grouped by day for the calendar [month].
  Future<Map<DateTime, List<ShopBookingModel>>> getBookingCalendar(
    DateTime month,
  );
}

/// Default implementation that communicates with the shop REST API.
class ShopBookingsRemoteDataSourceImpl
    implements ShopBookingsRemoteDataSource {
  const ShopBookingsRemoteDataSourceImpl({required ShopApiClient apiClient})
      : _apiClient = apiClient;

  final ShopApiClient _apiClient;

  @override
  Future<(List<ShopBookingModel>, int)> getBookings(
    BookingFilterModel filters,
  ) async {
    try {
      final response = await _apiClient.get(
        ShopApiEndpoints.bookings,
        queryParameters: filters.toQueryParams(),
      );
      final data = response['data'] as List<dynamic>;
      final totalCount = response['total_count'] as int? ?? data.length;
      final models = data
          .cast<Map<String, dynamic>>()
          .map(ShopBookingModel.fromJson)
          .toList();
      return (models, totalCount);
    } on ServerException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<ShopBookingModel> getBookingById(String id) async {
    try {
      final response = await _apiClient.get(
        ShopApiEndpoints.bookingDetail(id),
      );
      return ShopBookingModel.fromJson(response as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<ShopBookingModel> updateBookingStatus(
    String id,
    String status,
  ) async {
    try {
      final response = await _apiClient.patch(
        ShopApiEndpoints.bookingDetail(id),
        body: {'status': status},
      );
      return ShopBookingModel.fromJson(response as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<ShopBookingModel> cancelBooking(String id, String reason) async {
    try {
      final response = await _apiClient.post(
        ShopApiEndpoints.bookingCancel(id),
        body: {'reason': reason},
      );
      return ShopBookingModel.fromJson(response as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Map<DateTime, List<ShopBookingModel>>> getBookingCalendar(
    DateTime month,
  ) async {
    try {
      final response = await _apiClient.get(
        ShopApiEndpoints.bookingCalendar,
        queryParameters: {
          'year': month.year.toString(),
          'month': month.month.toString(),
        },
      );
      final raw = response as Map<String, dynamic>;
      final result = <DateTime, List<ShopBookingModel>>{};
      raw.forEach((key, value) {
        final date = DateTime.parse(key);
        final dayList = (value as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .map(ShopBookingModel.fromJson)
            .toList();
        result[date] = dayList;
      });
      return result;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
