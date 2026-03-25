import 'package:dartz/dartz.dart';
import '../entities/review.dart';
import '../repositories/review_repository.dart';

class EditReviewParams {
  final String reviewId;
  final double rating;
  final String title;
  final String text;
  final List<String> photos;

  const EditReviewParams({
    required this.reviewId,
    required this.rating,
    required this.title,
    required this.text,
    required this.photos,
  });
}

class EditReviewUsecase {
  final ReviewRepository repository;
  const EditReviewUsecase(this.repository);

  Future<Either<String, Review>> call(EditReviewParams params) =>
      repository.editReview(
        reviewId: params.reviewId,
        rating: params.rating,
        title: params.title,
        text: params.text,
        photos: params.photos,
      );
}
