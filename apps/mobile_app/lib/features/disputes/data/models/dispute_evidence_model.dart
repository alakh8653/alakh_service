import '../../domain/entities/dispute_evidence.dart';

class DisputeEvidenceModel extends DisputeEvidence {
  const DisputeEvidenceModel({
    required super.id,
    required super.type,
    required super.url,
    required super.description,
    required super.uploadedAt,
  });

  factory DisputeEvidenceModel.fromJson(Map<String, dynamic> json) {
    return DisputeEvidenceModel(
      id: json['id'] as String,
      type: EvidenceType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => EvidenceType.text,
      ),
      url: json['url'] as String,
      description: json['description'] as String,
      uploadedAt: DateTime.parse(json['uploaded_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'url': url,
        'description': description,
        'uploaded_at': uploadedAt.toIso8601String(),
      };
}
