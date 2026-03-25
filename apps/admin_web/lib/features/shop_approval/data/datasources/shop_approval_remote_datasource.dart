import 'package:dio/dio.dart';
import 'package:admin_web/core/core.dart';
import 'package:admin_web/features/shop_approval/data/models/shop_approval_model.dart';

abstract class ShopApprovalRemoteDatasource {
  Future<List<ShopApprovalModel>> getPendingShops({
    Map<String, dynamic>? params,
  });
  Future<List<ShopApprovalModel>> getAllShops({Map<String, dynamic>? params});
  Future<ShopApprovalModel> getShopById(String id);
  Future<ShopApprovalModel> approveShop(String id, {String? notes});
  Future<ShopApprovalModel> rejectShop(String id, String reason);
  Future<ShopApprovalModel> suspendShop(String id, String reason);
}

class ShopApprovalRemoteDatasourceImpl implements ShopApprovalRemoteDatasource {
  final AdminApiClient _apiClient;

  ShopApprovalRemoteDatasourceImpl(this._apiClient);

  @override
  Future<List<ShopApprovalModel>> getPendingShops({
    Map<String, dynamic>? params,
  }) async {
    try {
      final response = await _apiClient.get(
        AdminApiEndpoints.shopsPending,
        queryParameters: params,
      );
      final data = response.data as Map<String, dynamic>;
      final list = data['data'] as List<dynamic>? ??
          data['shops'] as List<dynamic>? ??
          [];
      return list
          .map((e) =>
              ShopApprovalModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to fetch pending shops');
    }
  }

  @override
  Future<List<ShopApprovalModel>> getAllShops({
    Map<String, dynamic>? params,
  }) async {
    try {
      final response = await _apiClient.get(
        AdminApiEndpoints.shops,
        queryParameters: params,
      );
      final data = response.data as Map<String, dynamic>;
      final list = data['data'] as List<dynamic>? ??
          data['shops'] as List<dynamic>? ??
          [];
      return list
          .map((e) =>
              ShopApprovalModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to fetch shops');
    }
  }

  @override
  Future<ShopApprovalModel> getShopById(String id) async {
    try {
      final response = await _apiClient.get(
        AdminApiEndpoints.withId(AdminApiEndpoints.shopById, id),
      );
      final data = response.data as Map<String, dynamic>;
      return ShopApprovalModel.fromJson(
          data['data'] as Map<String, dynamic>? ?? data);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to fetch shop');
    }
  }

  @override
  Future<ShopApprovalModel> approveShop(String id, {String? notes}) async {
    try {
      final response = await _apiClient.post(
        AdminApiEndpoints.withId(AdminApiEndpoints.shopApprove, id),
        data: notes != null ? {'notes': notes} : {},
      );
      final data = response.data as Map<String, dynamic>;
      return ShopApprovalModel.fromJson(
          data['data'] as Map<String, dynamic>? ?? data);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to approve shop');
    }
  }

  @override
  Future<ShopApprovalModel> rejectShop(String id, String reason) async {
    try {
      final response = await _apiClient.post(
        AdminApiEndpoints.withId(AdminApiEndpoints.shopReject, id),
        data: {'reason': reason},
      );
      final data = response.data as Map<String, dynamic>;
      return ShopApprovalModel.fromJson(
          data['data'] as Map<String, dynamic>? ?? data);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to reject shop');
    }
  }

  @override
  Future<ShopApprovalModel> suspendShop(String id, String reason) async {
    try {
      final response = await _apiClient.post(
        AdminApiEndpoints.withId('/admin/shops/{id}/suspend', id),
        data: {'reason': reason},
      );
      final data = response.data as Map<String, dynamic>;
      return ShopApprovalModel.fromJson(
          data['data'] as Map<String, dynamic>? ?? data);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to suspend shop');
    }
  }
}
