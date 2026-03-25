import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/fraud_alert.dart';
import '../entities/risk_score.dart';
import '../entities/blacklist_entry.dart';

/// Abstract repository for fraud monitoring.
abstract class FraudMonitoringRepository {
  Future<Either<Failure, List<FraudAlert>>> getFraudAlerts({String? severity, String? status});
  Future<Either<Failure, FraudAlert>> getFraudAlertById(String id);
  Future<Either<Failure, FraudAlert>> investigateAlert(String id, String notes);
  Future<Either<Failure, Unit>> dismissAlert(String id, String reason);
  Future<Either<Failure, Unit>> flagAccount(String userId, String reason, String severity);
  Future<Either<Failure, RiskScore>> getRiskScore(String entityId, String entityType);
  Future<Either<Failure, List<BlacklistEntry>>> getBlacklist({String? query});
  Future<Either<Failure, BlacklistEntry>> addToBlacklist(String entityId, String entityType, String reason);
  Future<Either<Failure, Unit>> removeFromBlacklist(String entryId);
  Future<Either<Failure, Map<String, dynamic>>> getFraudAnalytics(String period);
}
