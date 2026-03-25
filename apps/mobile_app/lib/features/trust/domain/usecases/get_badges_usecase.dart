import 'package:dartz/dartz.dart';
import '../entities/trust_badge.dart';
import '../repositories/trust_repository.dart';

class GetBadgesUsecase {
  final TrustRepository repository;
  const GetBadgesUsecase(this.repository);

  Future<Either<String, List<TrustBadge>>> call(String userId) =>
      repository.getBadges(userId);
}
