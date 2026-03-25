import 'package:dartz/dartz.dart';
import '../entities/review_stats.dart';
import '../repositories/review_repository.dart';

class GetReviewStatsUsecase {
  final ReviewRepository repository;
  const GetReviewStatsUsecase(this.repository);

  Future<Either<String, ReviewStats>> call(String shopId) =>
      repository.getReviewStats(shopId);
}
