import '../../domain/entities/fraud_alert.dart';

/// Data model for fraud alerts.
class FraudAlertModel extends FraudAlert {
  const FraudAlertModel({
    required super.id,
    required super.type,
    required super.severity,
    required super.userId,
    required super.details,
    required super.detectedAt,
    required super.status,
    super.notes,
  });

  factory FraudAlertModel.fromJson(Map<String, dynamic> json) => FraudAlertModel(
        id: json['id'] as String,
        type: json['type'] as String,
        severity: json['severity'] as String,
        userId: json['userId'] as String,
        details: (json['details'] as Map<String, dynamic>?) ?? {},
        detectedAt: DateTime.parse(json['detectedAt'] as String),
        status: json['status'] as String,
        notes: json['notes'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'severity': severity,
        'userId': userId,
        'details': details,
        'detectedAt': detectedAt.toIso8601String(),
        'status': status,
        'notes': notes,
      };
}
