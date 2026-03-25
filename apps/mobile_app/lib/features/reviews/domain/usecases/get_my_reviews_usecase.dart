import 'package:dartz/dartz.dart';
import '../entities/review.dart';
import '../repositories/review_repository.dart';

class GetMyReviewsUsecase {
  final ReviewRepository repository;
  const GetMyReviewsUsecase(this.repository);

  Future<Either<String, List<Review>>> call() => repository.getMyReviews();
}
