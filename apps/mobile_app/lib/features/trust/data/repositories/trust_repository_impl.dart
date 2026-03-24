import 'package:dartz/dartz.dart';
import '../datasources/trust_remote_datasource.dart';
import '../datasources/trust_local_datasource.dart';
import '../../domain/entities/trust_profile.dart';
import '../../domain/entities/trust_score.dart';
import '../../domain/entities/verification.dart';
import '../../domain/entities/verification_type.dart';
import '../../domain/entities/trust_badge.dart';
import '../../domain/entities/safety_report.dart';
import '../../domain/repositories/trust_repository.dart';

class TrustRepositoryImpl implements TrustRepository {
  final TrustRemoteDataSource remoteDataSource;
  final TrustLocalDataSource localDataSource;

  const TrustRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<String, TrustProfile>> getTrustProfile(String userId) async {
    try {
      final profile = await remoteDataSource.getTrustProfile(userId);
      await localDataSource.cacheTrustProfile(profile);
      return Right(profile);
    } catch (e) {
      final cached = await localDataSource.getCachedTrustProfile(userId);
      if (cached != null) return Right(cached);
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, TrustScore>> getTrustScore(String userId) async {
    try {
      final score = await remoteDataSource.getTrustScore(userId);
      return Right(score);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<Verification>>> getVerifications(
      String userId) async {
    try {
      final verifications =
          await remoteDataSource.getVerifications(userId);
      return Right(verifications);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, Verification>> startVerification({
    required String userId,
    required VerificationType type,
    required List<String> documentUrls,
  }) async {
    try {
      final verification = await remoteDataSource.startVerification(
        userId: userId,
        type: type,
        documentUrls: documentUrls,
      );
      return Right(verification);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<TrustBadge>>> getBadges(String userId) async {
    try {
      final badges = await remoteDataSource.getBadges(userId);
      return Right(badges);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, SafetyReport>> submitSafetyReport({
    required String reportedUserId,
    required String type,
    required String description,
  }) async {
    try {
      final report = await remoteDataSource.submitSafetyReport(
        reportedUserId: reportedUserId,
        type: type,
        description: description,
      );
      return Right(report);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<SafetyReport>>> getSafetyReports(
      String userId) async {
    try {
      final reports = await remoteDataSource.getSafetyReports(userId);
      return Right(reports);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
