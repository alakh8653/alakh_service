import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/fraud_alert.dart';
import '../repositories/fraud_monitoring_repository.dart';

/// Investigate a fraud alert.
class InvestigateAlertUsecase implements UseCase<FraudAlert, InvestigateAlertParams> {
  final FraudMonitoringRepository _repository;
  InvestigateAlertUsecase(this._repository);

  @override
  Future<Either<Failure, FraudAlert>> call(InvestigateAlertParams params) =>
      _repository.investigateAlert(params.id, params.notes);
}

class InvestigateAlertParams extends Equatable {
  final String id;
  final String notes;
  const InvestigateAlertParams({required this.id, required this.notes});
  @override
  List<Object> get props => [id, notes];
}

/// Dismiss a fraud alert.
class DismissAlertUsecase implements UseCase<Unit, DismissAlertParams> {
  final FraudMonitoringRepository _repository;
  DismissAlertUsecase(this._repository);

  @override
  Future<Either<Failure, Unit>> call(DismissAlertParams params) =>
      _repository.dismissAlert(params.id, params.reason);
}

class DismissAlertParams extends Equatable {
  final String id;
  final String reason;
  const DismissAlertParams({required this.id, required this.reason});
  @override
  List<Object> get props => [id, reason];
}

/// Flag a user account.
class FlagAccountUsecase implements UseCase<Unit, FlagAccountParams> {
  final FraudMonitoringRepository _repository;
  FlagAccountUsecase(this._repository);

  @override
  Future<Either<Failure, Unit>> call(FlagAccountParams params) =>
      _repository.flagAccount(params.userId, params.reason, params.severity);
}

class FlagAccountParams extends Equatable {
  final String userId;
  final String reason;
  final String severity;
  const FlagAccountParams({required this.userId, required this.reason, required this.severity});
  @override
  List<Object> get props => [userId, reason, severity];
}

/// Get risk score for entity.
class GetRiskScoreUsecase {
  final FraudMonitoringRepository _repository;
  GetRiskScoreUsecase(this._repository);

  Future<Either<Failure, dynamic>> call(String entityId, String entityType) =>
      _repository.getRiskScore(entityId, entityType);
}

/// Manage blacklist entries.
class GetBlacklistUsecase {
  final FraudMonitoringRepository _repository;
  GetBlacklistUsecase(this._repository);

  Future<Either<Failure, dynamic>> call({String? query}) =>
      _repository.getBlacklist(query: query);
}

class AddToBlacklistUsecase {
  final FraudMonitoringRepository _repository;
  AddToBlacklistUsecase(this._repository);

  Future<Either<Failure, dynamic>> call(String entityId, String entityType, String reason) =>
      _repository.addToBlacklist(entityId, entityType, reason);
}

class RemoveFromBlacklistUsecase {
  final FraudMonitoringRepository _repository;
  RemoveFromBlacklistUsecase(this._repository);

  Future<Either<Failure, Unit>> call(String entryId) =>
      _repository.removeFromBlacklist(entryId);
}
