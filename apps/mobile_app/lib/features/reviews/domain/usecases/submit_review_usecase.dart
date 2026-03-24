import 'package:dartz/dartz.dart';
import '../entities/review.dart';
import '../repositories/review_repository.dart';

class SubmitReviewParams {
  final String bookingId;
  final String shopId;
  final double rating;
  final String title;
  final String text;
  final List<String> photos;

  const SubmitReviewParams({
    required this.bookingId,
    required this.shopId,
    required this.rating,
    required this.title,
    required this.text,
    required this.photos,
  });
}

class SubmitReviewUsecase {
  final ReviewRepository repository;
  const SubmitReviewUsecase(this.repository);

  Future<Either<String, Review>> call(SubmitReviewParams params) =>
      repository.submitReview(
        bookingId: params.bookingId,
        shopId: params.shopId,
        rating: params.rating,
        title: params.title,
        text: params.text,
        photos: params.photos,
      );
}
