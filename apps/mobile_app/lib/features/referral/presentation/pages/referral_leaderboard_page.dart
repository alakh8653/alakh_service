import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/referral_bloc.dart';
import '../bloc/referral_event.dart';
import '../bloc/referral_state.dart';
import '../widgets/leaderboard_tile.dart';

/// Displays the referral leaderboard with the current user's entry
/// highlighted.
///
/// Expects a [ReferralBloc] available via [BlocProvider].
class ReferralLeaderboardPage extends StatefulWidget {
  /// Creates a [ReferralLeaderboardPage].
  const ReferralLeaderboardPage({super.key});

  /// Named route for navigation.
  static const routeName = '/referrals/leaderboard';

  @override
  State<ReferralLeaderboardPage> createState() =>
      _ReferralLeaderboardPageState();
}

class _ReferralLeaderboardPageState extends State<ReferralLeaderboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<ReferralBloc>().add(const LoadLeaderboard());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        centerTitle: true,
      ),
      body: BlocBuilder<ReferralBloc, ReferralState>(
        builder: (context, state) {
          if (state is ReferralLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ReferralError) {
            return _ErrorView(
              message: state.message,
              onRetry: () =>
                  context.read<ReferralBloc>().add(const LoadLeaderboard()),
            );
          }
          if (state is LeaderboardLoaded) {
            final entries = state.entries;
            if (entries.isEmpty) {
              return const _EmptyLeaderboard();
            }
            return RefreshIndicator(
              onRefresh: () async =>
                  context.read<ReferralBloc>().add(const LoadLeaderboard()),
              child: CustomScrollView(
                slivers: [
                  // Podium for top 3
                  if (entries.length >= 3)
                    SliverToBoxAdapter(
                      child: _Podium(entries: entries.take(3).toList()),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 8)),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) {
                        final entry = entries[i];
                        return LeaderboardTile(
                          rank: entry['rank'] as int? ?? i + 1,
                          name: entry['name'] as String? ?? 'Unknown',
                          earnings:
                              (entry['earnings'] as num?)?.toDouble() ?? 0.0,
                          currency: entry['currency'] as String? ?? 'INR',
                          isCurrentUser:
                              entry['isCurrentUser'] as bool? ?? false,
                        );
                      },
                      childCount: entries.length,
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

/// Top-3 podium widget displayed at the top of the leaderboard.
class _Podium extends StatelessWidget {
  const _Podium({required this.entries});

  final List<Map<String, dynamic>> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Arrange as 2nd, 1st, 3rd for the visual podium effect.
    final order = [1, 0, 2];
    final heights = [80.0, 110.0, 60.0];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.08),
            theme.colorScheme.secondary.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (i) {
          final idx = order[i];
          if (idx >= entries.length) return const SizedBox.shrink();
          final e = entries[idx];
          final medal = ['🥇', '🥈', '🥉'];
          return Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(medal[idx],
                    style: const TextStyle(fontSize: 28)),
                const SizedBox(height: 4),
                Text(
                  (e['name'] as String? ?? '').split(' ').first,
                  style: theme.textTheme.labelSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  height: heights[i],
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary
                        .withOpacity(0.15 + i * 0.05),
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(8)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${idx + 1}',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _EmptyLeaderboard extends StatelessWidget {
  const _EmptyLeaderboard();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.leaderboard_rounded,
              size: 64,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withOpacity(0.25)),
          const SizedBox(height: 16),
          Text(
            'Leaderboard is empty',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.5),
                ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 48, color: Colors.red),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
