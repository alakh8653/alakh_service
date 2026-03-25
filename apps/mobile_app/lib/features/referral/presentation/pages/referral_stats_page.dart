import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/referral_bloc.dart';
import '../bloc/referral_event.dart';
import '../bloc/referral_state.dart';
import '../widgets/referral_tier_progress.dart';

/// A detailed breakdown of the user's referral statistics, including an
/// earnings breakdown and tier progress.
///
/// Expects a [ReferralBloc] available via [BlocProvider].
class ReferralStatsPage extends StatefulWidget {
  /// Creates a [ReferralStatsPage].
  const ReferralStatsPage({super.key});

  /// Named route for navigation.
  static const routeName = '/referrals/stats';

  @override
  State<ReferralStatsPage> createState() => _ReferralStatsPageState();
}

class _ReferralStatsPageState extends State<ReferralStatsPage> {
  @override
  void initState() {
    super.initState();
    context.read<ReferralBloc>().add(const LoadReferralStats());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Referral Statistics')),
      body: BlocBuilder<ReferralBloc, ReferralState>(
        builder: (context, state) {
          if (state is ReferralLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ReferralError) {
            return _ErrorView(
              message: state.message,
              onRetry: () =>
                  context.read<ReferralBloc>().add(const LoadReferralStats()),
            );
          }
          if (state is StatsLoaded) {
            final stats = state.stats;
            return RefreshIndicator(
              onRefresh: () async =>
                  context.read<ReferralBloc>().add(const LoadReferralStats()),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  ReferralTierProgress(stats: stats),
                  const SizedBox(height: 20),
                  _SectionTitle('Earnings Overview'),
                  const SizedBox(height: 12),
                  _EarningsRow(
                    label: 'Total Earnings',
                    value:
                        '${stats.currency} ${stats.totalEarnings.toStringAsFixed(2)}',
                    icon: Icons.account_balance_wallet_rounded,
                    color: Colors.green,
                  ),
                  const Divider(height: 24),
                  _SectionTitle('Referral Counts'),
                  const SizedBox(height: 12),
                  _StatRow(
                    label: 'Total Referrals',
                    value: stats.totalReferrals.toString(),
                    icon: Icons.people_rounded,
                  ),
                  _StatRow(
                    label: 'Completed',
                    value: stats.completed.toString(),
                    icon: Icons.check_circle_outline_rounded,
                    valueColor: Colors.green,
                  ),
                  _StatRow(
                    label: 'Pending',
                    value: stats.pending.toString(),
                    icon: Icons.hourglass_top_rounded,
                    valueColor: Colors.orange,
                  ),
                  const Divider(height: 24),
                  _SectionTitle('Tier Information'),
                  const SizedBox(height: 12),
                  _StatRow(
                    label: 'Current Tier',
                    value: stats.currentTier,
                    icon: Icons.emoji_events_rounded,
                    valueColor: Colors.amber,
                  ),
                  if (stats.nextTierThreshold != null)
                    _StatRow(
                      label: 'Next Tier at',
                      value: '${stats.nextTierThreshold} referrals',
                      icon: Icons.trending_up_rounded,
                    ),
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context)
          .textTheme
          .titleSmall
          ?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

class _EarningsRow extends StatelessWidget {
  const _EarningsRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(label),
        trailing: Text(
          value,
          style: theme.textTheme.titleMedium
              ?.copyWith(color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon,
              size: 20,
              color: theme.colorScheme.onSurface.withOpacity(0.5)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: theme.textTheme.bodyMedium),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: valueColor,
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
          const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
