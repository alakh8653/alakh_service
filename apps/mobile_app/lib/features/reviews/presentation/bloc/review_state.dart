import 'package:equatable/equatable.dart';
import '../../domain/entities/review.dart';
import '../../domain/entities/review_stats.dart';

abstract class ReviewState extends Equatable {
  const ReviewState();
  @override
  List<Object?> get props => [];
}

class ReviewInitial extends ReviewState {
  const ReviewInitial();
}

class ReviewLoading extends ReviewState {
  const ReviewLoading();
}

class ReviewSubmitted extends ReviewState {
  final Review review;
  const ReviewSubmitted(this.review);
  @override
  List<Object?> get props => [review];
}

class ShopReviewsLoaded extends ReviewState {
  final List<Review> reviews;
  const ShopReviewsLoaded(this.reviews);
  @override
  List<Object?> get props => [reviews];
}

class MyReviewsLoaded extends ReviewState {
  final List<Review> reviews;
  const MyReviewsLoaded(this.reviews);
  @override
  List<Object?> get props => [reviews];
}

class ReviewDetailLoaded extends ReviewState {
  final Review review;
  const ReviewDetailLoaded(this.review);
  @override
  List<Object?> get props => [review];
}

class ReviewEdited extends ReviewState {
  final Review review;
  const ReviewEdited(this.review);
  @override
  List<Object?> get props => [review];
}

class ReviewDeleted extends ReviewState {
  const ReviewDeleted();
}

class ReviewReported extends ReviewState {
  const ReviewReported();
}

class ReviewHelpfulMarked extends ReviewState {
  const ReviewHelpfulMarked();
}

class ReviewStatsLoaded extends ReviewState {
  final ReviewStats stats;
  const ReviewStatsLoaded(this.stats);
  @override
  List<Object?> get props => [stats];
}

class ReviewError extends ReviewState {
  final String message;
  const ReviewError(this.message);
  @override
  List<Object?> get props => [message];
}
