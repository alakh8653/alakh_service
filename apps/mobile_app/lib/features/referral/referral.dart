/// Referral feature module – public API barrel file.
///
/// Import this single file to access all public classes from the referral
/// feature:
/// ```dart
/// import 'package:mobile_app/features/referral/referral.dart';
/// ```

// --------------------------------------------------------------------------
// Domain – Entities
// --------------------------------------------------------------------------
export 'domain/entities/referral.dart';
export 'domain/entities/referral_code.dart';
export 'domain/entities/referral_reward.dart';
export 'domain/entities/referral_stats.dart';
export 'domain/entities/referral_status.dart';

// --------------------------------------------------------------------------
// Domain – Repository contract
// --------------------------------------------------------------------------
export 'domain/repositories/referral_repository.dart';

// --------------------------------------------------------------------------
// Domain – Use Cases
// --------------------------------------------------------------------------
export 'domain/usecases/apply_referral_code_usecase.dart'
    show ApplyReferralCodeUseCase, ApplyReferralCodeParams;
export 'domain/usecases/claim_reward_usecase.dart'
    show ClaimRewardUseCase, ClaimRewardParams;
export 'domain/usecases/get_referral_code_usecase.dart'
    show GetReferralCodeUseCase, UseCase, NoParams;
export 'domain/usecases/get_referral_leaderboard_usecase.dart'
    show GetReferralLeaderboardUseCase;
export 'domain/usecases/get_referral_stats_usecase.dart'
    show GetReferralStatsUseCase;
export 'domain/usecases/get_referrals_usecase.dart' show GetReferralsUseCase;
export 'domain/usecases/share_referral_usecase.dart'
    show ShareReferralUseCase, ShareReferralParams;

// --------------------------------------------------------------------------
// Data – Models
// --------------------------------------------------------------------------
export 'data/models/referral_code_model.dart';
export 'data/models/referral_model.dart';
export 'data/models/referral_reward_model.dart';
export 'data/models/referral_stats_model.dart';

// --------------------------------------------------------------------------
// Data – Data Sources
// --------------------------------------------------------------------------
export 'data/datasources/referral_local_datasource.dart';
export 'data/datasources/referral_remote_datasource.dart';

// --------------------------------------------------------------------------
// Data – Repository Implementation
// --------------------------------------------------------------------------
export 'data/repositories/referral_repository_impl.dart';

// --------------------------------------------------------------------------
// Presentation – BLoC
// --------------------------------------------------------------------------
export 'presentation/bloc/referral_bloc.dart';
export 'presentation/bloc/referral_event.dart';
export 'presentation/bloc/referral_state.dart';

// --------------------------------------------------------------------------
// Presentation – Pages
// --------------------------------------------------------------------------
export 'presentation/pages/referral_history_page.dart';
export 'presentation/pages/referral_leaderboard_page.dart';
export 'presentation/pages/referral_page.dart';
export 'presentation/pages/referral_rewards_page.dart';
export 'presentation/pages/referral_stats_page.dart';

// --------------------------------------------------------------------------
// Presentation – Widgets
// --------------------------------------------------------------------------
export 'presentation/widgets/leaderboard_tile.dart';
export 'presentation/widgets/referral_code_card.dart';
export 'presentation/widgets/referral_list_item.dart';
export 'presentation/widgets/referral_stats_card.dart';
export 'presentation/widgets/referral_tier_progress.dart';
export 'presentation/widgets/reward_card.dart';
export 'presentation/widgets/share_referral_sheet.dart';
