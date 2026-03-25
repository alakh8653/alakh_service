import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/trust_profile_model.dart';
import '../models/trust_score_model.dart';
import '../models/verification_model.dart';
import '../models/badge_model.dart';
import '../models/safety_report_model.dart';
import '../../domain/entities/verification_type.dart';

abstract class TrustRemoteDataSource {
  Future<TrustProfileModel> getTrustProfile(String userId);
  Future<TrustScoreModel> getTrustScore(String userId);
  Future<List<VerificationModel>> getVerifications(String userId);
  Future<VerificationModel> startVerification({
    required String userId,
    required VerificationType type,
    required List<String> documentUrls,
  });
  Future<List<BadgeModel>> getBadges(String userId);
  Future<SafetyReportModel> submitSafetyReport({
    required String reportedUserId,
    required String type,
    required String description,
  });
  Future<List<SafetyReportModel>> getSafetyReports(String userId);
}

class TrustRemoteDataSourceImpl implements TrustRemoteDataSource {
  final http.Client client;
  final String baseUrl;
  final String authToken;

  const TrustRemoteDataSourceImpl({
    required this.client,
    required this.baseUrl,
    required this.authToken,
  });

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      };

  @override
  Future<TrustProfileModel> getTrustProfile(String userId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/api/v1/trust/profiles/$userId'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return TrustProfileModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to get trust profile: ${response.statusCode}');
  }

  @override
  Future<TrustScoreModel> getTrustScore(String userId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/api/v1/trust/scores/$userId'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return TrustScoreModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to get trust score: ${response.statusCode}');
  }

  @override
  Future<List<VerificationModel>> getVerifications(String userId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/api/v1/trust/verifications/$userId'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List<dynamic>;
      return list
          .map((e) => VerificationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to get verifications: ${response.statusCode}');
  }

  @override
  Future<VerificationModel> startVerification({
    required String userId,
    required VerificationType type,
    required List<String> documentUrls,
  }) async {
    final response = await client.post(
      Uri.parse('$baseUrl/api/v1/trust/verifications'),
      headers: _headers,
      body: jsonEncode({
        'user_id': userId,
        'type': type.name,
        'document_urls': documentUrls,
      }),
    );
    if (response.statusCode == 201) {
      return VerificationModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to start verification: ${response.statusCode}');
  }

  @override
  Future<List<BadgeModel>> getBadges(String userId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/api/v1/trust/badges/$userId'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List<dynamic>;
      return list
          .map((e) => BadgeModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to get badges: ${response.statusCode}');
  }

  @override
  Future<SafetyReportModel> submitSafetyReport({
    required String reportedUserId,
    required String type,
    required String description,
  }) async {
    final response = await client.post(
      Uri.parse('$baseUrl/api/v1/trust/safety-reports'),
      headers: _headers,
      body: jsonEncode({
        'reported_user_id': reportedUserId,
        'type': type,
        'description': description,
      }),
    );
    if (response.statusCode == 201) {
      return SafetyReportModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to submit safety report: ${response.statusCode}');
  }

  @override
  Future<List<SafetyReportModel>> getSafetyReports(String userId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/api/v1/trust/safety-reports/$userId'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List<dynamic>;
      return list
          .map((e) => SafetyReportModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to get safety reports: ${response.statusCode}');
  }
}
