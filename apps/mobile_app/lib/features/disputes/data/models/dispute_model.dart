import '../../domain/entities/dispute.dart';
import '../../domain/entities/dispute_type.dart';
import '../../domain/entities/dispute_status.dart';
import 'dispute_evidence_model.dart';
import 'dispute_message_model.dart';
import 'dispute_resolution_model.dart';

class DisputeModel extends Dispute {
  const DisputeModel({
    required super.id,
    required super.bookingId,
    required super.userId,
    required super.shopId,
    required super.type,
    required super.reason,
    required super.description,
    required super.status,
    required super.evidence,
    required super.messages,
    required super.createdAt,
    required super.updatedAt,
    super.resolution,
  });

  factory DisputeModel.fromJson(Map<String, dynamic> json) {
    return DisputeModel(
      id: json['id'] as String,
      bookingId: json['booking_id'] as String,
      userId: json['user_id'] as String,
      shopId: json['shop_id'] as String,
      type: DisputeType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => DisputeType.other,
      ),
      reason: json['reason'] as String,
      description: json['description'] as String,
      status: DisputeStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => DisputeStatus.draft,
      ),
      evidence: (json['evidence'] as List<dynamic>? ?? [])
          .map((e) => DisputeEvidenceModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      messages: (json['messages'] as List<dynamic>? ?? [])
          .map((m) => DisputeMessageModel.fromJson(m as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      resolution: json['resolution'] != null
          ? DisputeResolutionModel.fromJson(
              json['resolution'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'user_id': userId,
      'shop_id': shopId,
      'type': type.name,
      'reason': reason,
      'description': description,
      'status': status.name,
      'evidence': evidence
          .map((e) => (e as DisputeEvidenceModel).toJson())
          .toList(),
      'messages': messages
          .map((m) => (m as DisputeMessageModel).toJson())
          .toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'resolution': resolution != null
          ? (resolution as DisputeResolutionModel).toJson()
          : null,
    };
  }
}
