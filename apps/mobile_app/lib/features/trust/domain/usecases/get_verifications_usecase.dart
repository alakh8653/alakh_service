import 'package:dartz/dartz.dart';
import '../entities/verification.dart';
import '../repositories/trust_repository.dart';

class GetVerificationsUsecase {
  final TrustRepository repository;
  const GetVerificationsUsecase(this.repository);

  Future<Either<String, List<Verification>>> call(String userId) =>
      repository.getVerifications(userId);
}
