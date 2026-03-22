import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/referral_bloc.dart';
import '../bloc/referral_event.dart';
import '../bloc/referral_state.dart';
import '../widgets/referral_code_card.dart';
import '../widgets/referral_list_item.dart';
import '../widgets/referral_stats_card.dart';
import '../widgets/referral_tier_progress.dart';
import '../widgets/share_referral_sheet.dart';
import 'referral_history_page.dart';
import 'referral_leaderboard_page.dart';
import 'referral_rewards_page.dart';
import 'referral_stats_page.dart';

/// Main referral hub page.
///
/// Displays the user's referral code card, a stats summary, tier-progress
/// indicator, and a preview list of their most recent referrals.  Navigation
/// links lead to dedicated pages for full history, stats, leaderboard and
/// rewards.
///
/// Expects a [ReferralBloc] to be available via [BlocProvider] above this
/// widget in the tree.
class ReferralPage extends StatefulWidget {
  /// Creates a [ReferralPage].
  const ReferralPage({super.key});

  /// Named route for navigation.
  static const routeName = '/referrals';

  @override
  State<ReferralPage> createState() => _ReferralPageState();
}

class _ReferralPageState extends State<ReferralPage> {
  @override
  void initState() {
    super.initState();
    // Kick off parallel load of code and stats.
    context.read<ReferralBloc>()
      ..add(const LoadReferralCode())
      ..add(const LoadReferralStats())
      ..add(const LoadReferrals());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Refer & Earn'),
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard_rounded),
            tooltip: 'Leaderboard',
            onPressed: () => Navigator.of(context).pushNamed(
                ReferralLeaderboardPage.routeName),
          ),
          IconButton(
            icon: const Icon(Icons.card_giftcard_rounded),
            tooltip: 'Rewards',
            onPressed: () =>
                Navigator.of(context).pushNamed(ReferralRewardsPage.routeName),
          ),
        ],
      ),
      body: BlocConsumer<ReferralBloc, ReferralState>(
        listener: (context, state) {
          if (state is ShareContentReady) {
            // Show the share sheet once content is ready.
            final bloc = context.read<ReferralBloc>();
            ShareReferralSheet.show(
              context,
              referralCode:
                  (bloc.state is ReferralCodeLoaded)
                      ? (bloc.state as ReferralCodeLoaded).code
                      : (context
                              .findAncestorStateOfType<_ReferralPageState>()
                              ?._cachedCode ??
                          (throw StateError('No code available'))),
              shareContent: state.content,
              onShareViaWhatsApp: () {
                // TODO: Launch WhatsApp deep-link with share content.
              },
              onShareMore: () {
                // TODO: Invoke platform share sheet (e.g. share_plus package).
              },
            );
          } else if (state is ReferralError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ReferralLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<ReferralBloc>()
                ..add(const LoadReferralCode())
                ..add(const LoadReferralStats())
                ..add(const LoadReferrals());
            },
            child: _ReferralHubBody(
              onShareTap: (code) {
                context
                    .read<ReferralBloc>()
                    .add(ShareReferral(referralCode: code));
              },
              onViewAllReferrals: () =>
                  Navigator.of(context)
                      .pushNamed(ReferralHistoryPage.routeName),
              onViewStats: () =>
                  Navigator.of(context)
                      .pushNamed(ReferralStatsPage.routeName),
            ),
          );
        },
      ),
    );
  }

  // Cached code so it can be referenced inside the BlocConsumer listener.
  dynamic get _cachedCode => null;
}

/// Internal scrollable body of the [ReferralPage].
class _ReferralHubBody extends StatelessWidget {
  const _ReferralHubBody({
    required this.onShareTap,
    required this.onViewAllReferrals,
    required this.onViewStats,
  });

  final void Function(dynamic code) onShareTap;
  final VoidCallback onViewAllReferrals;
  final VoidCallback onViewStats;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        // Referral code card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: BlocBuilder<ReferralBloc, ReferralState>(
              buildWhen: (_, s) => s is ReferralCodeLoaded,
              builder: (context, state) {
                if (state is ReferralCodeLoaded) {
                  return ReferralCodeCard(
                    referralCode: state.code,
                    onShare: () => onShareTap(state.code),
                  );
                }
                return const _ShimmerCard(height: 160);
              },
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        // Stats summary card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: BlocBuilder<ReferralBloc, ReferralState>(
              buildWhen: (_, s) => s is StatsLoaded,
              builder: (context, state) {
                if (state is StatsLoaded) {
                  return Column(
                    children: [
                      ReferralStatsCard(
                        stats: state.stats,
                        onTap: onViewStats,
                      ),
                      const SizedBox(height: 12),
                      ReferralTierProgress(stats: state.stats),
                    ],
                  );
                }
                return const _ShimmerCard(height: 100);
              },
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        // Recent referrals header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Referrals',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: onViewAllReferrals,
                  child: const Text('See All'),
                ),
              ],
            ),
          ),
        ),

        // Recent referral list (first 5)
        BlocBuilder<ReferralBloc, ReferralState>(
          buildWhen: (_, s) => s is ReferralsLoaded,
          builder: (context, state) {
            if (state is ReferralsLoaded) {
              final preview = state.referrals.take(5).toList();
              if (preview.isEmpty) {
                return const SliverToBoxAdapter(
                  child: _EmptyReferrals(),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => ReferralListItem(referral: preview[i]),
                  childCount: preview.length,
                ),
              );
            }
            return const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            );
          },
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

class _EmptyReferrals extends StatelessWidget {
  const _EmptyReferrals();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Column(
        children: [
          Icon(Icons.people_outline_rounded,
              size: 56,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
          const SizedBox(height: 12),
          Text(
            'No referrals yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.5)),
          ),
          const SizedBox(height: 4),
          Text(
            'Share your code to start earning rewards!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.4)),
          ),
        ],
      ),
    );
  }
}
