import 'package:dartz/dartz.dart';
import '../repositories/review_repository.dart';

class ReportReviewParams {
  final String reviewId;
  final String reason;

  const ReportReviewParams({required this.reviewId, required this.reason});
}

class ReportReviewUsecase {
  final ReviewRepository repository;
  const ReportReviewUsecase(this.repository);

  Future<Either<String, bool>> call(ReportReviewParams params) =>
      repository.reportReview(
        reviewId: params.reviewId,
        reason: params.reason,
      );
}
