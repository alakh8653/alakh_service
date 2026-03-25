import 'package:dartz/dartz.dart';
import '../entities/safety_report.dart';
import '../repositories/trust_repository.dart';

class SubmitSafetyReportParams {
  final String reportedUserId;
  final String type;
  final String description;

  const SubmitSafetyReportParams({
    required this.reportedUserId,
    required this.type,
    required this.description,
  });
}

class SubmitSafetyReportUsecase {
  final TrustRepository repository;
  const SubmitSafetyReportUsecase(this.repository);

  Future<Either<String, SafetyReport>> call(SubmitSafetyReportParams params) =>
      repository.submitSafetyReport(
        reportedUserId: params.reportedUserId,
        type: params.type,
        description: params.description,
      );
}
