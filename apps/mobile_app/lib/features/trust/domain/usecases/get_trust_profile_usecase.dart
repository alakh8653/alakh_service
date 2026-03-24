import 'package:dartz/dartz.dart';
import '../entities/trust_profile.dart';
import '../repositories/trust_repository.dart';

class GetTrustProfileUsecase {
  final TrustRepository repository;
  const GetTrustProfileUsecase(this.repository);

  Future<Either<String, TrustProfile>> call(String userId) =>
      repository.getTrustProfile(userId);
}
