import 'package:dartz/dartz.dart';
import '../entities/trust_profile.dart';
import '../entities/trust_score.dart';
import '../entities/verification.dart';
import '../entities/verification_type.dart';
import '../entities/trust_badge.dart';
import '../entities/safety_report.dart';

abstract class TrustRepository {
  Future<Either<String, TrustProfile>> getTrustProfile(String userId);
  Future<Either<String, TrustScore>> getTrustScore(String userId);
  Future<Either<String, List<Verification>>> getVerifications(String userId);
  Future<Either<String, Verification>> startVerification({
    required String userId,
    required VerificationType type,
    required List<String> documentUrls,
  });
  Future<Either<String, List<TrustBadge>>> getBadges(String userId);
  Future<Either<String, SafetyReport>> submitSafetyReport({
    required String reportedUserId,
    required String type,
    required String description,
  });
  Future<Either<String, List<SafetyReport>>> getSafetyReports(String userId);
}
