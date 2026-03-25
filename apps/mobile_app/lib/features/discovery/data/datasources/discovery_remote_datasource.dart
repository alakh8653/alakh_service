import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/failures.dart';
import '../models/models.dart';

/// Contract for the remote (API) data source.
abstract class DiscoveryRemoteDataSource {
  Future<List<ShopModel>> searchShops({
    required String query,
    FilterModel? filters,
  });

  Future<List<ShopModel>> getNearbyShops({
    required double latitude,
    required double longitude,
    required double radiusKm,
  });

  Future<List<CategoryModel>> getCategories();

  Future<ShopModel> getShopDetails(String shopId);

  Future<List<ServiceModel>> getShopServices(String shopId);

  Future<List<ServiceModel>> getTrendingServices();

  Future<void> addToFavorites(String shopId);

  Future<void> removeFromFavorites(String shopId);

  Future<List<ShopModel>> getFavorites();
}

/// HTTP implementation of [DiscoveryRemoteDataSource].
class DiscoveryRemoteDataSourceImpl implements DiscoveryRemoteDataSource {
  DiscoveryRemoteDataSourceImpl({
    required this.httpClient,
    required this.baseUrl,
  });

  final http.Client httpClient;
  final String baseUrl;

  // ── helpers ────────────────────────────────────────────────────────────────

  Future<dynamic> _get(String path,
      [Map<String, String>? queryParams]) async {
    final uri = Uri.parse('$baseUrl$path').replace(
      queryParameters: queryParams,
    );
    final response = await httpClient.get(uri, headers: _headers);
    return _parseResponse(response);
  }

  Future<dynamic> _post(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await httpClient.post(
      uri,
      headers: _headers,
      body: jsonEncode(body),
    );
    return _parseResponse(response);
  }

  Future<dynamic> _delete(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await httpClient.delete(uri, headers: _headers);
    return _parseResponse(response);
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  dynamic _parseResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    }
    throw ServerFailure(
        'Server error ${response.statusCode}: ${response.body}');
  }

  // ── interface implementation ───────────────────────────────────────────────

  @override
  Future<List<ShopModel>> searchShops({
    required String query,
    FilterModel? filters,
  }) async {
    final params = <String, String>{'q': query};
    if (filters != null) {
      final json = filters.toJson();
      json.forEach((k, v) => params[k] = v.toString());
    }
    final data = await _get('/discovery/search', params) as List;
    return data
        .map((e) => ShopModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ShopModel>> getNearbyShops({
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) async {
    final data = await _get('/discovery/nearby', {
      'lat': latitude.toString(),
      'lng': longitude.toString(),
      'radius': radiusKm.toString(),
    }) as List;
    return data
        .map((e) => ShopModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    final data = await _get('/discovery/categories') as List;
    return data
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ShopModel> getShopDetails(String shopId) async {
    final data = await _get('/discovery/shops/$shopId');
    return ShopModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<List<ServiceModel>> getShopServices(String shopId) async {
    final data = await _get('/discovery/shops/$shopId/services') as List;
    return data
        .map((e) => ServiceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ServiceModel>> getTrendingServices() async {
    final data = await _get('/discovery/trending') as List;
    return data
        .map((e) => ServiceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> addToFavorites(String shopId) async {
    await _post('/discovery/favorites', {'shop_id': shopId});
  }

  @override
  Future<void> removeFromFavorites(String shopId) async {
    await _delete('/discovery/favorites/$shopId');
  }

  @override
  Future<List<ShopModel>> getFavorites() async {
    final data = await _get('/discovery/favorites') as List;
    return data
        .map((e) => ShopModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
