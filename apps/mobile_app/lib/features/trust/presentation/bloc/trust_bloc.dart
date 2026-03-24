import 'package:flutter_bloc/flutter_bloc.dart';
import 'trust_event.dart';
import 'trust_state.dart';
import '../../domain/usecases/get_trust_profile_usecase.dart';
import '../../domain/usecases/get_trust_score_usecase.dart';
import '../../domain/usecases/get_verifications_usecase.dart';
import '../../domain/usecases/start_verification_usecase.dart';
import '../../domain/usecases/get_badges_usecase.dart';
import '../../domain/usecases/submit_safety_report_usecase.dart';

class TrustBloc extends Bloc<TrustEvent, TrustState> {
  final GetTrustProfileUsecase getTrustProfileUsecase;
  final GetTrustScoreUsecase getTrustScoreUsecase;
  final GetVerificationsUsecase getVerificationsUsecase;
  final StartVerificationUsecase startVerificationUsecase;
  final GetBadgesUsecase getBadgesUsecase;
  final SubmitSafetyReportUsecase submitSafetyReportUsecase;

  TrustBloc({
    required this.getTrustProfileUsecase,
    required this.getTrustScoreUsecase,
    required this.getVerificationsUsecase,
    required this.startVerificationUsecase,
    required this.getBadgesUsecase,
    required this.submitSafetyReportUsecase,
  }) : super(const TrustInitial()) {
    on<LoadTrustProfileEvent>(_onLoadProfile);
    on<LoadTrustScoreEvent>(_onLoadScore);
    on<LoadVerificationsEvent>(_onLoadVerifications);
    on<StartVerificationEvent>(_onStartVerification);
    on<LoadBadgesEvent>(_onLoadBadges);
    on<SubmitSafetyReportEvent>(_onSubmitSafetyReport);
  }

  Future<void> _onLoadProfile(
      LoadTrustProfileEvent event, Emitter<TrustState> emit) async {
    emit(const TrustLoading());
    final result = await getTrustProfileUsecase(event.userId);
    result.fold(
      (error) => emit(TrustError(error)),
      (profile) => emit(TrustProfileLoaded(profile)),
    );
  }

  Future<void> _onLoadScore(
      LoadTrustScoreEvent event, Emitter<TrustState> emit) async {
    emit(const TrustLoading());
    final result = await getTrustScoreUsecase(event.userId);
    result.fold(
      (error) => emit(TrustError(error)),
      (score) => emit(TrustScoreLoaded(score)),
    );
  }

  Future<void> _onLoadVerifications(
      LoadVerificationsEvent event, Emitter<TrustState> emit) async {
    emit(const TrustLoading());
    final result = await getVerificationsUsecase(event.userId);
    result.fold(
      (error) => emit(TrustError(error)),
      (verifications) => emit(VerificationsLoaded(verifications)),
    );
  }

  Future<void> _onStartVerification(
      StartVerificationEvent event, Emitter<TrustState> emit) async {
    emit(const TrustLoading());
    final result = await startVerificationUsecase(StartVerificationParams(
      userId: event.userId,
      type: event.type,
      documentUrls: event.documentUrls,
    ));
    result.fold(
      (error) => emit(TrustError(error)),
      (verification) => emit(VerificationStarted(verification)),
    );
  }

  Future<void> _onLoadBadges(
      LoadBadgesEvent event, Emitter<TrustState> emit) async {
    emit(const TrustLoading());
    final result = await getBadgesUsecase(event.userId);
    result.fold(
      (error) => emit(TrustError(error)),
      (badges) => emit(BadgesLoaded(badges)),
    );
  }

  Future<void> _onSubmitSafetyReport(
      SubmitSafetyReportEvent event, Emitter<TrustState> emit) async {
    emit(const TrustLoading());
    final result = await submitSafetyReportUsecase(SubmitSafetyReportParams(
      reportedUserId: event.reportedUserId,
      type: event.type,
      description: event.description,
    ));
    result.fold(
      (error) => emit(TrustError(error)),
      (report) => emit(SafetyReportSubmitted(report)),
    );
  }
}
