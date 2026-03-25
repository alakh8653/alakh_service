import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/fraud_alert.dart';
import '../repositories/fraud_monitoring_repository.dart';

/// Fetches fraud alerts with optional filters.
class GetFraudAlertsUsecase implements UseCase<List<FraudAlert>, GetFraudAlertsParams> {
  final FraudMonitoringRepository _repository;
  GetFraudAlertsUsecase(this._repository);

  @override
  Future<Either<Failure, List<FraudAlert>>> call(GetFraudAlertsParams params) =>
      _repository.getFraudAlerts(severity: params.severity, status: params.status);
}

class GetFraudAlertsParams extends Equatable {
  final String? severity;
  final String? status;
  const GetFraudAlertsParams({this.severity, this.status});
  @override
  List<Object?> get props => [severity, status];
}
