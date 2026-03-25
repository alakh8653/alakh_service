import 'package:dartz/dartz.dart';
import '../entities/review.dart';
import '../repositories/review_repository.dart';

class GetReviewDetailsUsecase {
  final ReviewRepository repository;
  const GetReviewDetailsUsecase(this.repository);

  Future<Either<String, Review>> call(String reviewId) =>
      repository.getReviewDetails(reviewId);
}
