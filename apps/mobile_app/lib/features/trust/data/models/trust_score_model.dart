import '../../domain/entities/trust_score.dart';

class TrustScoreModel extends TrustScore {
  const TrustScoreModel({
    required super.overall,
    required super.components,
    required super.lastUpdated,
    required super.trend,
  });

  factory TrustScoreModel.fromJson(Map<String, dynamic> json) {
    return TrustScoreModel(
      overall: (json['overall'] as num).toDouble(),
      components: (json['components'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, (v as num).toDouble()),
      ),
      lastUpdated: DateTime.parse(json['last_updated'] as String),
      trend: (json['trend'] as num? ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'overall': overall,
        'components': components,
        'last_updated': lastUpdated.toIso8601String(),
        'trend': trend,
      };
}
