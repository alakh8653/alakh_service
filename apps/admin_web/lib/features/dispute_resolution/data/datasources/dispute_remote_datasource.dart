import 'package:dio/dio.dart';
import 'package:admin_web/core/core.dart';
import 'package:admin_web/features/dispute_resolution/data/models/dispute_model.dart';

abstract class DisputeRemoteDatasource {
  Future<List<DisputeModel>> getDisputes({Map<String, dynamic>? params});
  Future<DisputeModel> getDisputeById(String id);
  Future<DisputeModel> updateDisputeStatus(
      String id, String status, String? notes);
  Future<DisputeModel> resolveDispute(String id, String resolution);
  Future<DisputeModel> escalateDispute(String id, String reason);
  Future<DisputeModel> assignDispute(String id, String adminId);
}

class DisputeRemoteDatasourceImpl implements DisputeRemoteDatasource {
  final AdminApiClient _apiClient;

  DisputeRemoteDatasourceImpl(this._apiClient);

  @override
  Future<List<DisputeModel>> getDisputes({
    Map<String, dynamic>? params,
  }) async {
    try {
      final response = await _apiClient.get(
        AdminApiEndpoints.disputes,
        queryParameters: params,
      );
      final data = response.data as Map<String, dynamic>;
      final list = data['data'] as List<dynamic>? ??
          data['disputes'] as List<dynamic>? ??
          [];
      return list
          .map((e) => DisputeModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to fetch disputes');
    }
  }

  @override
  Future<DisputeModel> getDisputeById(String id) async {
    try {
      final response = await _apiClient.get(
        AdminApiEndpoints.withId(AdminApiEndpoints.disputeById, id),
      );
      final data = response.data as Map<String, dynamic>;
      return DisputeModel.fromJson(data['data'] as Map<String, dynamic>? ?? data);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to fetch dispute');
    }
  }

  @override
  Future<DisputeModel> updateDisputeStatus(
      String id, String status, String? notes) async {
    try {
      final response = await _apiClient.patch(
        AdminApiEndpoints.withId('/admin/disputes/{id}/status', id),
        data: {
          'status': status,
          if (notes != null) 'notes': notes,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return DisputeModel.fromJson(data['data'] as Map<String, dynamic>? ?? data);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to update dispute status');
    }
  }

  @override
  Future<DisputeModel> resolveDispute(String id, String resolution) async {
    try {
      final response = await _apiClient.post(
        AdminApiEndpoints.withId(AdminApiEndpoints.disputeResolve, id),
        data: {'resolution': resolution},
      );
      final data = response.data as Map<String, dynamic>;
      return DisputeModel.fromJson(data['data'] as Map<String, dynamic>? ?? data);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to resolve dispute');
    }
  }

  @override
  Future<DisputeModel> escalateDispute(String id, String reason) async {
    try {
      final response = await _apiClient.post(
        AdminApiEndpoints.withId('/admin/disputes/{id}/escalate', id),
        data: {'reason': reason},
      );
      final data = response.data as Map<String, dynamic>;
      return DisputeModel.fromJson(data['data'] as Map<String, dynamic>? ?? data);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to escalate dispute');
    }
  }

  @override
  Future<DisputeModel> assignDispute(String id, String adminId) async {
    try {
      final response = await _apiClient.post(
        AdminApiEndpoints.withId('/admin/disputes/{id}/assign', id),
        data: {'adminId': adminId},
      );
      final data = response.data as Map<String, dynamic>;
      return DisputeModel.fromJson(data['data'] as Map<String, dynamic>? ?? data);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to assign dispute');
    }
  }
}
