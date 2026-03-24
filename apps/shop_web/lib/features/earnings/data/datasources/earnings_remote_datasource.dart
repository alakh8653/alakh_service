import '../../../../core/errors/shop_exceptions.dart';
import '../../../../core/network/shop_api_client.dart';
import '../../../../core/network/shop_api_endpoints.dart';
import '../models/earnings_model.dart';
import '../models/earnings_breakdown_model.dart';

/// Abstract data source for earnings remote operations.
abstract class EarningsRemoteDataSource {
  Future<EarningsModel> getEarnings(DateTime startDate, DateTime endDate);
  Future<List<EarningsBreakdownModel>> getEarningsBreakdown(String period);
  Future<Map<String, dynamic>> comparePeriods(String period1, String period2);
}

/// Implementation of [EarningsRemoteDataSource] using Dio.
class EarningsRemoteDataSourceImpl implements EarningsRemoteDataSource {
  EarningsRemoteDataSourceImpl(this._apiClient);
  final ShopApiClient _apiClient;

  @override
  Future<EarningsModel> getEarnings(DateTime startDate, DateTime endDate) async {
    try {
      final response = await _apiClient.dio.get(
        ShopApiEndpoints.earnings,
        queryParameters: {
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
        },
      );
      return EarningsModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<EarningsBreakdownModel>> getEarningsBreakdown(String period) async {
    try {
      final response = await _apiClient.dio.get(
        '${ShopApiEndpoints.earnings}/breakdown',
        queryParameters: {'period': period},
      );
      return (response.data as List)
          .map((e) => EarningsBreakdownModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> comparePeriods(String period1, String period2) async {
    try {
      final response = await _apiClient.dio.get(
        '${ShopApiEndpoints.earnings}/compare',
        queryParameters: {'period1': period1, 'period2': period2},
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
