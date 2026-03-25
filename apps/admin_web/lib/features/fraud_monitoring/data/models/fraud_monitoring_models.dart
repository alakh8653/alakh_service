import '../../domain/entities/risk_score.dart';
import '../../domain/entities/blacklist_entry.dart';

/// Data model for risk scores.
class RiskScoreModel extends RiskScore {
  const RiskScoreModel({
    required super.entityId,
    required super.entityType,
    required super.overallScore,
    required super.components,
    required super.signals,
    required super.calculatedAt,
  });

  factory RiskScoreModel.fromJson(Map<String, dynamic> json) => RiskScoreModel(
        entityId: json['entityId'] as String,
        entityType: json['entityType'] as String,
        overallScore: (json['overallScore'] as num).toDouble(),
        components: Map<String, double>.from(
          ((json['components'] as Map<String, dynamic>?) ?? {})
              .map((k, v) => MapEntry(k, (v as num).toDouble())),
        ),
        signals: List<String>.from((json['signals'] as List?) ?? []),
        calculatedAt: DateTime.parse(json['calculatedAt'] as String),
      );
}

/// Data model for blacklist entries.
class BlacklistEntryModel extends BlacklistEntry {
  const BlacklistEntryModel({
    required super.id,
    required super.entityId,
    required super.entityType,
    required super.reason,
    required super.addedAt,
    required super.addedBy,
    super.expiresAt,
  });

  factory BlacklistEntryModel.fromJson(Map<String, dynamic> json) => BlacklistEntryModel(
        id: json['id'] as String,
        entityId: json['entityId'] as String,
        entityType: json['entityType'] as String,
        reason: json['reason'] as String,
        addedAt: DateTime.parse(json['addedAt'] as String),
        addedBy: json['addedBy'] as String,
        expiresAt: json['expiresAt'] != null
            ? DateTime.parse(json['expiresAt'] as String)
            : null,
      );
}
