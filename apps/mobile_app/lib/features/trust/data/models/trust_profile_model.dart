import '../../domain/entities/trust_profile.dart';
import 'trust_score_model.dart';
import 'verification_model.dart';
import 'badge_model.dart';
import 'safety_report_model.dart';

class TrustProfileModel extends TrustProfile {
  const TrustProfileModel({
    required super.userId,
    required super.score,
    required super.verifications,
    required super.badges,
    required super.safetyReports,
  });

  factory TrustProfileModel.fromJson(Map<String, dynamic> json) {
    return TrustProfileModel(
      userId: json['user_id'] as String,
      score: TrustScoreModel.fromJson(json['score'] as Map<String, dynamic>),
      verifications: (json['verifications'] as List<dynamic>? ?? [])
          .map((e) => VerificationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      badges: (json['badges'] as List<dynamic>? ?? [])
          .map((e) => BadgeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      safetyReports: (json['safety_reports'] as List<dynamic>? ?? [])
          .map((e) => SafetyReportModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'score': (score as TrustScoreModel).toJson(),
        'verifications': verifications
            .map((v) => (v as VerificationModel).toJson())
            .toList(),
        'badges':
            badges.map((b) => (b as BadgeModel).toJson()).toList(),
        'safety_reports': safetyReports
            .map((r) => (r as SafetyReportModel).toJson())
            .toList(),
      };
}
