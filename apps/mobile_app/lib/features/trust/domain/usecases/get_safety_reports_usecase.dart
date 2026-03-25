import 'package:dartz/dartz.dart';
import '../entities/safety_report.dart';
import '../repositories/trust_repository.dart';

class GetSafetyReportsUsecase {
  final TrustRepository repository;
  const GetSafetyReportsUsecase(this.repository);

  Future<Either<String, List<SafetyReport>>> call(String userId) =>
      repository.getSafetyReports(userId);
}
