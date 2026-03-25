import 'package:equatable/equatable.dart';

abstract class ReviewEvent extends Equatable {
  const ReviewEvent();
  @override
  List<Object?> get props => [];
}

class SubmitReviewEvent extends ReviewEvent {
  final String bookingId;
  final String shopId;
  final double rating;
  final String title;
  final String text;
  final List<String> photos;

  const SubmitReviewEvent({
    required this.bookingId,
    required this.shopId,
    required this.rating,
    required this.title,
    required this.text,
    required this.photos,
  });

  @override
  List<Object?> get props => [bookingId, shopId, rating, title, text, photos];
}

class LoadShopReviewsEvent extends ReviewEvent {
  final String shopId;
  final int? filterRating;

  const LoadShopReviewsEvent({required this.shopId, this.filterRating});

  @override
  List<Object?> get props => [shopId, filterRating];
}

class LoadMyReviewsEvent extends ReviewEvent {
  const LoadMyReviewsEvent();
}

class LoadReviewDetailsEvent extends ReviewEvent {
  final String reviewId;
  const LoadReviewDetailsEvent(this.reviewId);
  @override
  List<Object?> get props => [reviewId];
}

class EditReviewEvent extends ReviewEvent {
  final String reviewId;
  final double rating;
  final String title;
  final String text;
  final List<String> photos;

  const EditReviewEvent({
    required this.reviewId,
    required this.rating,
    required this.title,
    required this.text,
    required this.photos,
  });

  @override
  List<Object?> get props => [reviewId, rating, title, text, photos];
}

class DeleteReviewEvent extends ReviewEvent {
  final String reviewId;
  const DeleteReviewEvent(this.reviewId);
  @override
  List<Object?> get props => [reviewId];
}

class ReportReviewEvent extends ReviewEvent {
  final String reviewId;
  final String reason;
  const ReportReviewEvent({required this.reviewId, required this.reason});
  @override
  List<Object?> get props => [reviewId, reason];
}

class MarkReviewHelpfulEvent extends ReviewEvent {
  final String reviewId;
  const MarkReviewHelpfulEvent(this.reviewId);
  @override
  List<Object?> get props => [reviewId];
}

class LoadReviewStatsEvent extends ReviewEvent {
  final String shopId;
  const LoadReviewStatsEvent(this.shopId);
  @override
  List<Object?> get props => [shopId];
}

class RespondToReviewEvent extends ReviewEvent {
  final String reviewId;
  final String content;
  const RespondToReviewEvent({required this.reviewId, required this.content});
  @override
  List<Object?> get props => [reviewId, content];
}
