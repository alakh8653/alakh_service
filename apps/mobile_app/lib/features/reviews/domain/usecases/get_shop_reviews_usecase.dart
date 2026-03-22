import 'package:dartz/dartz.dart';
import '../entities/review.dart';
import '../repositories/review_repository.dart';

class GetShopReviewsParams {
  final String shopId;
  final int? page;
  final int? perPage;
  final int? filterRating;

  const GetShopReviewsParams({
    required this.shopId,
    this.page,
    this.perPage,
    this.filterRating,
  });
}

class GetShopReviewsUsecase {
  final ReviewRepository repository;
  const GetShopReviewsUsecase(this.repository);

  Future<Either<String, List<Review>>> call(GetShopReviewsParams params) =>
      repository.getShopReviews(
        shopId: params.shopId,
        page: params.page,
        perPage: params.perPage,
        filterRating: params.filterRating,
      );
}
