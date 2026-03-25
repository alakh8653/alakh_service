import 'package:flutter_bloc/flutter_bloc.dart';
import 'review_event.dart';
import 'review_state.dart';
import '../../domain/usecases/submit_review_usecase.dart';
import '../../domain/usecases/get_shop_reviews_usecase.dart';
import '../../domain/usecases/get_my_reviews_usecase.dart';
import '../../domain/usecases/get_review_details_usecase.dart';
import '../../domain/usecases/edit_review_usecase.dart';
import '../../domain/usecases/delete_review_usecase.dart';
import '../../domain/usecases/report_review_usecase.dart';
import '../../domain/usecases/mark_review_helpful_usecase.dart';
import '../../domain/usecases/get_review_stats_usecase.dart';
import '../../domain/usecases/respond_to_review_usecase.dart';

class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final SubmitReviewUsecase submitReviewUsecase;
  final GetShopReviewsUsecase getShopReviewsUsecase;
  final GetMyReviewsUsecase getMyReviewsUsecase;
  final GetReviewDetailsUsecase getReviewDetailsUsecase;
  final EditReviewUsecase editReviewUsecase;
  final DeleteReviewUsecase deleteReviewUsecase;
  final ReportReviewUsecase reportReviewUsecase;
  final MarkReviewHelpfulUsecase markReviewHelpfulUsecase;
  final GetReviewStatsUsecase getReviewStatsUsecase;
  final RespondToReviewUsecase respondToReviewUsecase;

  ReviewBloc({
    required this.submitReviewUsecase,
    required this.getShopReviewsUsecase,
    required this.getMyReviewsUsecase,
    required this.getReviewDetailsUsecase,
    required this.editReviewUsecase,
    required this.deleteReviewUsecase,
    required this.reportReviewUsecase,
    required this.markReviewHelpfulUsecase,
    required this.getReviewStatsUsecase,
    required this.respondToReviewUsecase,
  }) : super(const ReviewInitial()) {
    on<SubmitReviewEvent>(_onSubmit);
    on<LoadShopReviewsEvent>(_onLoadShop);
    on<LoadMyReviewsEvent>(_onLoadMine);
    on<LoadReviewDetailsEvent>(_onLoadDetails);
    on<EditReviewEvent>(_onEdit);
    on<DeleteReviewEvent>(_onDelete);
    on<ReportReviewEvent>(_onReport);
    on<MarkReviewHelpfulEvent>(_onHelpful);
    on<LoadReviewStatsEvent>(_onStats);
    on<RespondToReviewEvent>(_onRespond);
  }

  Future<void> _onSubmit(SubmitReviewEvent e, Emitter<ReviewState> emit) async {
    emit(const ReviewLoading());
    final result = await submitReviewUsecase(SubmitReviewParams(
      bookingId: e.bookingId,
      shopId: e.shopId,
      rating: e.rating,
      title: e.title,
      text: e.text,
      photos: e.photos,
    ));
    result.fold(
      (err) => emit(ReviewError(err)),
      (review) => emit(ReviewSubmitted(review)),
    );
  }

  Future<void> _onLoadShop(
      LoadShopReviewsEvent e, Emitter<ReviewState> emit) async {
    emit(const ReviewLoading());
    final result = await getShopReviewsUsecase(GetShopReviewsParams(
      shopId: e.shopId,
      filterRating: e.filterRating,
    ));
    result.fold(
      (err) => emit(ReviewError(err)),
      (reviews) => emit(ShopReviewsLoaded(reviews)),
    );
  }

  Future<void> _onLoadMine(
      LoadMyReviewsEvent e, Emitter<ReviewState> emit) async {
    emit(const ReviewLoading());
    final result = await getMyReviewsUsecase();
    result.fold(
      (err) => emit(ReviewError(err)),
      (reviews) => emit(MyReviewsLoaded(reviews)),
    );
  }

  Future<void> _onLoadDetails(
      LoadReviewDetailsEvent e, Emitter<ReviewState> emit) async {
    emit(const ReviewLoading());
    final result = await getReviewDetailsUsecase(e.reviewId);
    result.fold(
      (err) => emit(ReviewError(err)),
      (review) => emit(ReviewDetailLoaded(review)),
    );
  }

  Future<void> _onEdit(EditReviewEvent e, Emitter<ReviewState> emit) async {
    emit(const ReviewLoading());
    final result = await editReviewUsecase(EditReviewParams(
      reviewId: e.reviewId,
      rating: e.rating,
      title: e.title,
      text: e.text,
      photos: e.photos,
    ));
    result.fold(
      (err) => emit(ReviewError(err)),
      (review) => emit(ReviewEdited(review)),
    );
  }

  Future<void> _onDelete(DeleteReviewEvent e, Emitter<ReviewState> emit) async {
    emit(const ReviewLoading());
    final result = await deleteReviewUsecase(e.reviewId);
    result.fold(
      (err) => emit(ReviewError(err)),
      (_) => emit(const ReviewDeleted()),
    );
  }

  Future<void> _onReport(ReportReviewEvent e, Emitter<ReviewState> emit) async {
    emit(const ReviewLoading());
    final result = await reportReviewUsecase(
        ReportReviewParams(reviewId: e.reviewId, reason: e.reason));
    result.fold(
      (err) => emit(ReviewError(err)),
      (_) => emit(const ReviewReported()),
    );
  }

  Future<void> _onHelpful(
      MarkReviewHelpfulEvent e, Emitter<ReviewState> emit) async {
    final result = await markReviewHelpfulUsecase(e.reviewId);
    result.fold(
      (err) => emit(ReviewError(err)),
      (_) => emit(const ReviewHelpfulMarked()),
    );
  }

  Future<void> _onStats(LoadReviewStatsEvent e, Emitter<ReviewState> emit) async {
    emit(const ReviewLoading());
    final result = await getReviewStatsUsecase(e.shopId);
    result.fold(
      (err) => emit(ReviewError(err)),
      (stats) => emit(ReviewStatsLoaded(stats)),
    );
  }

  Future<void> _onRespond(
      RespondToReviewEvent e, Emitter<ReviewState> emit) async {
    emit(const ReviewLoading());
    final result = await respondToReviewUsecase(
        RespondToReviewParams(reviewId: e.reviewId, content: e.content));
    result.fold(
      (err) => emit(ReviewError(err)),
      (review) => emit(ReviewEdited(review)),
    );
  }
}
