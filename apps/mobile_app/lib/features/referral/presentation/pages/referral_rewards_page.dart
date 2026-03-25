import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/referral_reward.dart';
import '../bloc/referral_bloc.dart';
import '../bloc/referral_event.dart';
import '../bloc/referral_state.dart';
import '../widgets/reward_card.dart';

/// Displays the user's referral rewards, grouped into "Available" and
/// "Claimed / Expired" sections.
///
/// The user can tap the Claim button on available rewards to trigger the
/// [ClaimReward] event.
///
/// Expects a [ReferralBloc] available via [BlocProvider].
///
/// Note: This page currently sources reward data from a dedicated BLoC event.
/// In a full implementation, you may add a `LoadRewards` event and
/// `RewardsLoaded` state, or fetch rewards as part of [LoadReferralStats].
class ReferralRewardsPage extends StatefulWidget {
  /// Creates a [ReferralRewardsPage].
  const ReferralRewardsPage({super.key});

  /// Named route for navigation.
  static const routeName = '/referrals/rewards';

  @override
  State<ReferralRewardsPage> createState() => _ReferralRewardsPageState();
}

class _ReferralRewardsPageState extends State<ReferralRewardsPage> {
  /// Tracks which reward ID is currently being claimed (shows a loader).
  String? _claimingId;

  // TODO: Replace with a real `LoadRewards` event/state when the BLoC is
  // extended to support paginated rewards.  For now we use mock data so the
  // page structure is complete and testable.
  List<ReferralReward> _rewards = [];

  @override
  void initState() {
    super.initState();
    _loadMockRewards();
  }

  void _loadMockRewards() {
    // TODO: Remove mock data and dispatch a real LoadRewards event.
    setState(() {
      _rewards = [
        const ReferralReward(
          id: 'reward_1',
          type: RewardType.cashback,
          amount: 150,
          currency: 'INR',
          status: RewardStatus.available,
        ),
        const ReferralReward(
          id: 'reward_2',
          type: RewardType.credit,
          amount: 200,
          currency: 'INR',
          status: RewardStatus.claimed,
        ),
        const ReferralReward(
          id: 'reward_3',
          type: RewardType.discount,
          amount: 10,
          currency: 'INR',
          status: RewardStatus.available,
        ),
        const ReferralReward(
          id: 'reward_4',
          type: RewardType.cashback,
          amount: 75,
          currency: 'INR',
          status: RewardStatus.expired,
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    final available =
        _rewards.where((r) => r.status == RewardStatus.available).toList();
    final past = _rewards
        .where((r) =>
            r.status == RewardStatus.claimed ||
            r.status == RewardStatus.expired)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('My Rewards')),
      body: BlocListener<ReferralBloc, ReferralState>(
        listener: (context, state) {
          if (state is RewardClaimed) {
            setState(() {
              _claimingId = null;
              // Update local list to reflect claimed status.
              _rewards = _rewards.map((r) {
                if (r.id == state.reward.id) return state.reward;
                return r;
              }).toList();
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Reward of ${state.reward.currency} '
                  '${state.reward.amount.toStringAsFixed(0)} claimed!',
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is ReferralError) {
            setState(() => _claimingId = null);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: _rewards.isEmpty
            ? const _EmptyRewards()
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (available.isNotEmpty) ...[
                    _SectionHeader(
                      title: 'Available',
                      count: available.length,
                    ),
                    const SizedBox(height: 8),
                    ...available.map(
                      (reward) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: RewardCard(
                          reward: reward,
                          isLoading: _claimingId == reward.id,
                          onClaim: () {
                            setState(() => _claimingId = reward.id);
                            context
                                .read<ReferralBloc>()
                                .add(ClaimReward(rewardId: reward.id));
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (past.isNotEmpty) ...[
                    _SectionHeader(
                      title: 'Past Rewards',
                      count: past.length,
                    ),
                    const SizedBox(height: 8),
                    ...past.map(
                      (reward) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: RewardCard(reward: reward),
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyRewards extends StatelessWidget {
  const _EmptyRewards();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.card_giftcard_rounded,
            size: 64,
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withOpacity(0.25),
          ),
          const SizedBox(height: 16),
          Text(
            'No rewards yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.5),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete referrals to earn rewards!',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.4),
                ),
          ),
        ],
      ),
    );
  }
}
