import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dispute_model.dart';
import '../models/dispute_evidence_model.dart';
import '../models/dispute_message_model.dart';
import '../../domain/entities/dispute_type.dart';
import '../../domain/entities/dispute_evidence.dart';

abstract class DisputeRemoteDataSource {
  Future<DisputeModel> createDispute({
    required String bookingId,
    required DisputeType type,
    required String reason,
    required String description,
  });

  Future<DisputeModel> getDisputeDetails(String disputeId);

  Future<List<DisputeModel>> getMyDisputes({bool? activeOnly});

  Future<DisputeEvidenceModel> submitEvidence({
    required String disputeId,
    required EvidenceType evidenceType,
    required String url,
    required String description,
  });

  Future<DisputeMessageModel> respondToDispute({
    required String disputeId,
    required String content,
  });

  Future<DisputeModel> escalateDispute({
    required String disputeId,
    required String reason,
  });

  Future<bool> cancelDispute(String disputeId);

  Future<DisputeModel> acceptResolution(String disputeId);
}

class DisputeRemoteDataSourceImpl implements DisputeRemoteDataSource {
  final http.Client client;
  final String baseUrl;
  final String authToken;

  const DisputeRemoteDataSourceImpl({
    required this.client,
    required this.baseUrl,
    required this.authToken,
  });

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      };

  @override
  Future<DisputeModel> createDispute({
    required String bookingId,
    required DisputeType type,
    required String reason,
    required String description,
  }) async {
    final response = await client.post(
      Uri.parse('$baseUrl/api/v1/disputes'),
      headers: _headers,
      body: jsonEncode({
        'booking_id': bookingId,
        'type': type.name,
        'reason': reason,
        'description': description,
      }),
    );
    if (response.statusCode == 201) {
      return DisputeModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to create dispute: ${response.statusCode}');
  }

  @override
  Future<DisputeModel> getDisputeDetails(String disputeId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/api/v1/disputes/$disputeId'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return DisputeModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to get dispute: ${response.statusCode}');
  }

  @override
  Future<List<DisputeModel>> getMyDisputes({bool? activeOnly}) async {
    final uri = Uri.parse('$baseUrl/api/v1/disputes/mine').replace(
      queryParameters: activeOnly != null
          ? {'active_only': activeOnly.toString()}
          : null,
    );
    final response = await client.get(uri, headers: _headers);
    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List<dynamic>;
      return list
          .map((e) => DisputeModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to get disputes: ${response.statusCode}');
  }

  @override
  Future<DisputeEvidenceModel> submitEvidence({
    required String disputeId,
    required EvidenceType evidenceType,
    required String url,
    required String description,
  }) async {
    final response = await client.post(
      Uri.parse('$baseUrl/api/v1/disputes/$disputeId/evidence'),
      headers: _headers,
      body: jsonEncode({
        'type': evidenceType.name,
        'url': url,
        'description': description,
      }),
    );
    if (response.statusCode == 201) {
      return DisputeEvidenceModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to submit evidence: ${response.statusCode}');
  }

  @override
  Future<DisputeMessageModel> respondToDispute({
    required String disputeId,
    required String content,
  }) async {
    final response = await client.post(
      Uri.parse('$baseUrl/api/v1/disputes/$disputeId/messages'),
      headers: _headers,
      body: jsonEncode({'content': content}),
    );
    if (response.statusCode == 201) {
      return DisputeMessageModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to respond to dispute: ${response.statusCode}');
  }

  @override
  Future<DisputeModel> escalateDispute({
    required String disputeId,
    required String reason,
  }) async {
    final response = await client.post(
      Uri.parse('$baseUrl/api/v1/disputes/$disputeId/escalate'),
      headers: _headers,
      body: jsonEncode({'reason': reason}),
    );
    if (response.statusCode == 200) {
      return DisputeModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to escalate dispute: ${response.statusCode}');
  }

  @override
  Future<bool> cancelDispute(String disputeId) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/api/v1/disputes/$disputeId'),
      headers: _headers,
    );
    return response.statusCode == 200 || response.statusCode == 204;
  }

  @override
  Future<DisputeModel> acceptResolution(String disputeId) async {
    final response = await client.post(
      Uri.parse('$baseUrl/api/v1/disputes/$disputeId/accept-resolution'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return DisputeModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to accept resolution: ${response.statusCode}');
  }
}
