import 'package:shop_web/core/errors/shop_exceptions.dart';
import 'package:shop_web/core/network/shop_api_client.dart';
import 'package:shop_web/core/network/shop_api_endpoints.dart';
import 'package:shop_web/features/dashboard/data/models/dashboard_summary_model.dart';
import 'package:shop_web/features/dashboard/data/models/recent_activity_model.dart';
import 'package:shop_web/features/dashboard/data/models/revenue_data_model.dart';

/// Contract for the dashboard remote data source.
abstract class DashboardRemoteDataSource {
  /// Fetches the dashboard summary KPIs from the API.
  Future<DashboardSummaryModel> getDashboardSummary();

  /// Fetches revenue chart data for the specified date range.
  Future<List<RevenueDataModel>> getRevenueChart(
    DateTime startDate,
    DateTime endDate,
  );

  /// Fetches the [limit] most-recent activity events.
  Future<List<RecentActivityModel>> getRecentActivity(int limit);
}

/// [ShopApiClient]-backed implementation of [DashboardRemoteDataSource].
///
/// All methods throw [ServerException] on non-2xx responses and
/// [NetworkException] when the device has no connectivity.
class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final ShopApiClient _apiClient;

  const DashboardRemoteDataSourceImpl({required ShopApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<DashboardSummaryModel> getDashboardSummary() async {
    final response = await _apiClient.get(ShopApiEndpoints.dashboardSummary);
    final data = response['data'] as Map<String, dynamic>? ?? response;
    return DashboardSummaryModel.fromJson(data);
  }

  @override
  Future<List<RevenueDataModel>> getRevenueChart(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final response = await _apiClient.get(
      ShopApiEndpoints.revenueChart,
      queryParameters: {
        'start_date': startDate.toIso8601String().substring(0, 10),
        'end_date': endDate.toIso8601String().substring(0, 10),
      },
    );
    final list = response['data'] as List<dynamic>? ?? [];
    return list
        .map((e) => RevenueDataModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<RecentActivityModel>> getRecentActivity(int limit) async {
    final response = await _apiClient.get(
      ShopApiEndpoints.recentActivity,
      queryParameters: {'limit': limit.toString()},
    );
    final list = response['data'] as List<dynamic>? ?? [];
    return list
        .map((e) => RecentActivityModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
