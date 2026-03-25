import '../../domain/entities/verification.dart';
import '../../domain/entities/verification_type.dart';
import '../../domain/entities/verification_status.dart';

class VerificationModel extends Verification {
  const VerificationModel({
    required super.id,
    required super.type,
    required super.status,
    super.verifiedAt,
    super.expiresAt,
    super.documents,
  });

  factory VerificationModel.fromJson(Map<String, dynamic> json) {
    return VerificationModel(
      id: json['id'] as String,
      type: VerificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => VerificationType.identity,
      ),
      status: VerificationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => VerificationStatus.notStarted,
      ),
      verifiedAt: json['verified_at'] != null
          ? DateTime.parse(json['verified_at'] as String)
          : null,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      documents: (json['documents'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'status': status.name,
        'verified_at': verifiedAt?.toIso8601String(),
        'expires_at': expiresAt?.toIso8601String(),
        'documents': documents,
      };
}
