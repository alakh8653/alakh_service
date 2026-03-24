import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/apply_referral_code_usecase.dart';
import '../../domain/usecases/claim_reward_usecase.dart';
import '../../domain/usecases/get_referral_code_usecase.dart';
import '../../domain/usecases/get_referral_leaderboard_usecase.dart';
import '../../domain/usecases/get_referral_stats_usecase.dart';
import '../../domain/usecases/get_referrals_usecase.dart';
import '../../domain/usecases/share_referral_usecase.dart';
import 'referral_event.dart';
import 'referral_state.dart';

/// BLoC that orchestrates all referral-related business operations for the
/// presentation layer.
///
/// Inject through a [BlocProvider] at the route or widget-tree level above any
/// page that consumes referral state.
class ReferralBloc extends Bloc<ReferralEvent, ReferralState> {
  /// Creates a [ReferralBloc] with all required use-case dependencies.
  ReferralBloc({
    required GetReferralCodeUseCase getReferralCode,
    required GetReferralStatsUseCase getReferralStats,
    required GetReferralsUseCase getReferrals,
    required ClaimRewardUseCase claimReward,
    required ApplyReferralCodeUseCase applyReferralCode,
    required ShareReferralUseCase shareReferral,
    required GetReferralLeaderboardUseCase getLeaderboard,
  })  : _getReferralCode = getReferralCode,
        _getReferralStats = getReferralStats,
        _getReferrals = getReferrals,
        _claimReward = claimReward,
        _applyReferralCode = applyReferralCode,
        _shareReferral = shareReferral,
        _getLeaderboard = getLeaderboard,
        super(const ReferralInitial()) {
    on<LoadReferralCode>(_onLoadReferralCode);
    on<LoadReferralStats>(_onLoadReferralStats);
    on<LoadReferrals>(_onLoadReferrals);
    on<ClaimReward>(_onClaimReward);
    on<ApplyCode>(_onApplyCode);
    on<ShareReferral>(_onShareReferral);
    on<LoadLeaderboard>(_onLoadLeaderboard);
  }

  final GetReferralCodeUseCase _getReferralCode;
  final GetReferralStatsUseCase _getReferralStats;
  final GetReferralsUseCase _getReferrals;
  final ClaimRewardUseCase _claimReward;
  final ApplyReferralCodeUseCase _applyReferralCode;
  final ShareReferralUseCase _shareReferral;
  final GetReferralLeaderboardUseCase _getLeaderboard;

  Future<void> _onLoadReferralCode(
    LoadReferralCode event,
    Emitter<ReferralState> emit,
  ) async {
    emit(const ReferralLoading());
    final result = await _getReferralCode(const NoParams());
    result.fold(
      (failure) => emit(ReferralError(message: failure.message)),
      (code) => emit(ReferralCodeLoaded(code: code)),
    );
  }

  Future<void> _onLoadReferralStats(
    LoadReferralStats event,
    Emitter<ReferralState> emit,
  ) async {
    emit(const ReferralLoading());
    final result = await _getReferralStats(const NoParams());
    result.fold(
      (failure) => emit(ReferralError(message: failure.message)),
      (stats) => emit(StatsLoaded(stats: stats)),
    );
  }

  Future<void> _onLoadReferrals(
    LoadReferrals event,
    Emitter<ReferralState> emit,
  ) async {
    emit(const ReferralLoading());
    final result = await _getReferrals(const NoParams());
    result.fold(
      (failure) => emit(ReferralError(message: failure.message)),
      (referrals) => emit(ReferralsLoaded(referrals: referrals)),
    );
  }

  Future<void> _onClaimReward(
    ClaimReward event,
    Emitter<ReferralState> emit,
  ) async {
    emit(const ReferralLoading());
    final result =
        await _claimReward(ClaimRewardParams(rewardId: event.rewardId));
    result.fold(
      (failure) => emit(ReferralError(message: failure.message)),
      (reward) => emit(RewardClaimed(reward: reward)),
    );
  }

  Future<void> _onApplyCode(
    ApplyCode event,
    Emitter<ReferralState> emit,
  ) async {
    emit(const ReferralLoading());
    final result = await _applyReferralCode(
        ApplyReferralCodeParams(code: event.code));
    result.fold(
      (failure) => emit(ReferralError(message: failure.message)),
      (success) {
        if (success) {
          emit(const CodeApplied());
        } else {
          emit(const ReferralError(message: 'Referral code could not be applied.'));
        }
      },
    );
  }

  Future<void> _onShareReferral(
    ShareReferral event,
    Emitter<ReferralState> emit,
  ) async {
    emit(const ReferralLoading());
    final result = await _shareReferral(
        ShareReferralParams(referralCode: event.referralCode));
    result.fold(
      (failure) => emit(ReferralError(message: failure.message)),
      (content) => emit(ShareContentReady(content: content)),
    );
  }

  Future<void> _onLoadLeaderboard(
    LoadLeaderboard event,
    Emitter<ReferralState> emit,
  ) async {
    emit(const ReferralLoading());
    final result = await _getLeaderboard(const NoParams());
    result.fold(
      (failure) => emit(ReferralError(message: failure.message)),
      (entries) => emit(LeaderboardLoaded(entries: entries)),
    );
  }
}
