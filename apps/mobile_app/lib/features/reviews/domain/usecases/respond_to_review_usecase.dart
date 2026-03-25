import 'package:dartz/dartz.dart';
import '../entities/review.dart';
import '../repositories/review_repository.dart';

class RespondToReviewParams {
  final String reviewId;
  final String content;

  const RespondToReviewParams({required this.reviewId, required this.content});
}

class RespondToReviewUsecase {
  final ReviewRepository repository;
  const RespondToReviewUsecase(this.repository);

  Future<Either<String, Review>> call(RespondToReviewParams params) =>
      repository.respondToReview(
        reviewId: params.reviewId,
        content: params.content,
      );
}
