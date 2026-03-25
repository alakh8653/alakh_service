import 'package:dio/dio.dart';
import 'package:admin_web/core/core.dart';
import 'package:admin_web/features/city_management/data/models/city_model.dart';

abstract class CityRemoteDatasource {
  Future<List<CityModel>> getCities({Map<String, dynamic>? params});
  Future<CityModel> getCityById(String id);
  Future<CityModel> createCity(Map<String, dynamic> data);
  Future<CityModel> updateCity(String id, Map<String, dynamic> data);
  Future<void> deleteCity(String id);
  Future<CityModel> toggleCityStatus(String id, bool active);
}

class CityRemoteDatasourceImpl implements CityRemoteDatasource {
  final AdminApiClient _apiClient;

  CityRemoteDatasourceImpl(this._apiClient);

  @override
  Future<List<CityModel>> getCities({Map<String, dynamic>? params}) async {
    try {
      final response = await _apiClient.get(
        AdminApiEndpoints.cities,
        queryParameters: params,
      );
      final data = response.data as Map<String, dynamic>;
      final list = data['data'] as List<dynamic>? ?? data['cities'] as List<dynamic>? ?? [];
      return list.map((e) => CityModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to fetch cities');
    }
  }

  @override
  Future<CityModel> getCityById(String id) async {
    try {
      final response = await _apiClient.get(
        AdminApiEndpoints.withId(AdminApiEndpoints.cityById, id),
      );
      final data = response.data as Map<String, dynamic>;
      return CityModel.fromJson(data['data'] as Map<String, dynamic>? ?? data);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to fetch city');
    }
  }

  @override
  Future<CityModel> createCity(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post(
        AdminApiEndpoints.cities,
        data: data,
      );
      final responseData = response.data as Map<String, dynamic>;
      return CityModel.fromJson(
          responseData['data'] as Map<String, dynamic>? ?? responseData);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to create city');
    }
  }

  @override
  Future<CityModel> updateCity(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put(
        AdminApiEndpoints.withId(AdminApiEndpoints.cityById, id),
        data: data,
      );
      final responseData = response.data as Map<String, dynamic>;
      return CityModel.fromJson(
          responseData['data'] as Map<String, dynamic>? ?? responseData);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to update city');
    }
  }

  @override
  Future<void> deleteCity(String id) async {
    try {
      await _apiClient.delete(
        AdminApiEndpoints.withId(AdminApiEndpoints.cityById, id),
      );
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to delete city');
    }
  }

  @override
  Future<CityModel> toggleCityStatus(String id, bool active) async {
    try {
      final response = await _apiClient.patch(
        AdminApiEndpoints.withId('/admin/cities/{id}/status', id),
        data: {'isActive': active},
      );
      final responseData = response.data as Map<String, dynamic>;
      return CityModel.fromJson(
          responseData['data'] as Map<String, dynamic>? ?? responseData);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to toggle city status');
    }
  }
}
