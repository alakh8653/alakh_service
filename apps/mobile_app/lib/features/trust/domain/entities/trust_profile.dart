import 'package:equatable/equatable.dart';
import 'trust_score.dart';
import 'verification.dart';
import 'trust_badge.dart';
import 'safety_report.dart';

class TrustProfile extends Equatable {
  final String userId;
  final TrustScore score;
  final List<Verification> verifications;
  final List<TrustBadge> badges;
  final List<SafetyReport> safetyReports;

  const TrustProfile({
    required this.userId,
    required this.score,
    required this.verifications,
    required this.badges,
    required this.safetyReports,
  });

  int get verifiedCount =>
      verifications.where((v) => v.status.isActive).length;

  @override
  List<Object?> get props =>
      [userId, score, verifications, badges, safetyReports];
}
