import 'package:dartz/dartz.dart';
import '../repositories/review_repository.dart';

class MarkReviewHelpfulUsecase {
  final ReviewRepository repository;
  const MarkReviewHelpfulUsecase(this.repository);

  Future<Either<String, bool>> call(String reviewId) =>
      repository.markReviewHelpful(reviewId);
}
