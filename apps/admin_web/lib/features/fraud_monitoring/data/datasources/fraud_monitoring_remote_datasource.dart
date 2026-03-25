import '../../../../core/network/admin_api_client.dart';
import '../../../../core/network/admin_api_endpoints.dart';
import '../models/fraud_alert_model.dart';
import '../models/fraud_monitoring_models.dart';

/// Remote datasource for fraud monitoring.
abstract class FraudMonitoringRemoteDatasource {
  Future<List<FraudAlertModel>> getFraudAlerts({String? severity, String? status});
  Future<FraudAlertModel> investigateAlert(String id, String notes);
  Future<void> dismissAlert(String id, String reason);
  Future<void> flagAccount(String userId, String reason, String severity);
  Future<RiskScoreModel> getRiskScore(String entityId, String entityType);
  Future<List<BlacklistEntryModel>> getBlacklist({String? query});
  Future<BlacklistEntryModel> addToBlacklist(String entityId, String entityType, String reason);
  Future<void> removeFromBlacklist(String entryId);
  Future<Map<String, dynamic>> getFraudAnalytics(String period);
}

class FraudMonitoringRemoteDatasourceImpl implements FraudMonitoringRemoteDatasource {
  final AdminApiClient _apiClient;
  FraudMonitoringRemoteDatasourceImpl(this._apiClient);

  @override
  Future<List<FraudAlertModel>> getFraudAlerts({String? severity, String? status}) async {
    final params = <String, dynamic>{
      if (severity != null) 'severity': severity,
      if (status != null) 'status': status,
    };
    final response = await _apiClient.get(
      AdminApiEndpoints.fraudAlerts,
      queryParameters: params,
    );
    return (response.data['data'] as List)
        .map((e) => FraudAlertModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<FraudAlertModel> investigateAlert(String id, String notes) async {
    final response = await _apiClient.post(
      '${AdminApiEndpoints.fraudAlerts}/$id/investigate',
      data: {'notes': notes},
    );
    return FraudAlertModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> dismissAlert(String id, String reason) =>
      _apiClient.post('${AdminApiEndpoints.fraudAlerts}/$id/dismiss', data: {'reason': reason});

  @override
  Future<void> flagAccount(String userId, String reason, String severity) =>
      _apiClient.post(AdminApiEndpoints.flagAccount, data: {
        'userId': userId,
        'reason': reason,
        'severity': severity,
      });

  @override
  Future<RiskScoreModel> getRiskScore(String entityId, String entityType) async {
    final response = await _apiClient.get(
      AdminApiEndpoints.riskScore,
      queryParameters: {'entityId': entityId, 'entityType': entityType},
    );
    return RiskScoreModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<List<BlacklistEntryModel>> getBlacklist({String? query}) async {
    final response = await _apiClient.get(
      AdminApiEndpoints.blacklist,
      queryParameters: {if (query != null) 'q': query},
    );
    return (response.data['data'] as List)
        .map((e) => BlacklistEntryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<BlacklistEntryModel> addToBlacklist(
      String entityId, String entityType, String reason) async {
    final response = await _apiClient.post(
      AdminApiEndpoints.blacklist,
      data: {'entityId': entityId, 'entityType': entityType, 'reason': reason},
    );
    return BlacklistEntryModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> removeFromBlacklist(String entryId) =>
      _apiClient.delete('${AdminApiEndpoints.blacklist}/$entryId');

  @override
  Future<Map<String, dynamic>> getFraudAnalytics(String period) async {
    final response = await _apiClient.get(
      AdminApiEndpoints.fraudAnalytics,
      queryParameters: {'period': period},
    );
    return response.data['data'] as Map<String, dynamic>;
  }
}
