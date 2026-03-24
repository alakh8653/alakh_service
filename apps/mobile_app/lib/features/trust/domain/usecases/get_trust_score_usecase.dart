import 'package:dartz/dartz.dart';
import '../entities/trust_score.dart';
import '../repositories/trust_repository.dart';

class GetTrustScoreUsecase {
  final TrustRepository repository;
  const GetTrustScoreUsecase(this.repository);

  Future<Either<String, TrustScore>> call(String userId) =>
      repository.getTrustScore(userId);
}
