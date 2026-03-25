import 'package:dartz/dartz.dart';
import '../entities/review.dart';
import '../entities/review_stats.dart';

abstract class ReviewRepository {
  Future<Either<String, Review>> submitReview({
    required String bookingId,
    required String shopId,
    required double rating,
    required String title,
    required String text,
    required List<String> photos,
  });

  Future<Either<String, List<Review>>> getShopReviews({
    required String shopId,
    int? page,
    int? perPage,
    int? filterRating,
  });

  Future<Either<String, List<Review>>> getMyReviews();

  Future<Either<String, Review>> getReviewDetails(String reviewId);

  Future<Either<String, Review>> editReview({
    required String reviewId,
    required double rating,
    required String title,
    required String text,
    required List<String> photos,
  });

  Future<Either<String, bool>> deleteReview(String reviewId);

  Future<Either<String, bool>> reportReview({
    required String reviewId,
    required String reason,
  });

  Future<Either<String, bool>> markReviewHelpful(String reviewId);

  Future<Either<String, ReviewStats>> getReviewStats(String shopId);

  Future<Either<String, Review>> respondToReview({
    required String reviewId,
    required String content,
  });
}
