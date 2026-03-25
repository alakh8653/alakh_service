import 'package:dartz/dartz.dart';
import '../datasources/review_remote_datasource.dart';
import '../datasources/review_local_datasource.dart';
import '../../domain/entities/review.dart';
import '../../domain/entities/review_stats.dart';
import '../../domain/repositories/review_repository.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource remoteDataSource;
  final ReviewLocalDataSource localDataSource;

  const ReviewRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<String, Review>> submitReview({
    required String bookingId,
    required String shopId,
    required double rating,
    required String title,
    required String text,
    required List<String> photos,
  }) async {
    try {
      final review = await remoteDataSource.submitReview(
        bookingId: bookingId,
        shopId: shopId,
        rating: rating,
        title: title,
        text: text,
        photos: photos,
      );
      return Right(review);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<Review>>> getShopReviews({
    required String shopId,
    int? page,
    int? perPage,
    int? filterRating,
  }) async {
    try {
      final reviews = await remoteDataSource.getShopReviews(
        shopId: shopId,
        page: page,
        perPage: perPage,
        filterRating: filterRating,
      );
      await localDataSource.cacheShopReviews(shopId, reviews);
      return Right(reviews);
    } catch (e) {
      final cached = await localDataSource.getCachedShopReviews(shopId);
      if (cached.isNotEmpty) return Right(cached);
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<Review>>> getMyReviews() async {
    try {
      final reviews = await remoteDataSource.getMyReviews();
      await localDataSource.cacheMyReviews(reviews);
      return Right(reviews);
    } catch (e) {
      final cached = await localDataSource.getCachedMyReviews();
      if (cached.isNotEmpty) return Right(cached);
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, Review>> getReviewDetails(String reviewId) async {
    try {
      final review = await remoteDataSource.getReviewDetails(reviewId);
      return Right(review);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, Review>> editReview({
    required String reviewId,
    required double rating,
    required String title,
    required String text,
    required List<String> photos,
  }) async {
    try {
      final review = await remoteDataSource.editReview(
        reviewId: reviewId,
        rating: rating,
        title: title,
        text: text,
        photos: photos,
      );
      return Right(review);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, bool>> deleteReview(String reviewId) async {
    try {
      final result = await remoteDataSource.deleteReview(reviewId);
      return Right(result);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, bool>> reportReview({
    required String reviewId,
    required String reason,
  }) async {
    try {
      final result = await remoteDataSource.reportReview(
        reviewId: reviewId,
        reason: reason,
      );
      return Right(result);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, bool>> markReviewHelpful(String reviewId) async {
    try {
      final result = await remoteDataSource.markReviewHelpful(reviewId);
      return Right(result);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, ReviewStats>> getReviewStats(String shopId) async {
    try {
      final stats = await remoteDataSource.getReviewStats(shopId);
      return Right(stats);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, Review>> respondToReview({
    required String reviewId,
    required String content,
  }) async {
    try {
      final review = await remoteDataSource.respondToReview(
        reviewId: reviewId,
        content: content,
      );
      return Right(review);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
