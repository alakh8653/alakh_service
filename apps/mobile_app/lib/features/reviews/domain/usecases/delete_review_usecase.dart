import 'package:dartz/dartz.dart';
import '../repositories/review_repository.dart';

class DeleteReviewUsecase {
  final ReviewRepository repository;
  const DeleteReviewUsecase(this.repository);

  Future<Either<String, bool>> call(String reviewId) =>
      repository.deleteReview(reviewId);
}
