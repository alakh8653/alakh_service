import 'package:flutter/material.dart';

import '../../domain/entities/referral_stats.dart';

/// A compact summary card displaying key referral statistics: total referrals,
/// pending count, and total earnings.
///
/// Intended for use on the referral hub page as a quick-glance overview before
/// the user navigates to the full stats page.
class ReferralStatsCard extends StatelessWidget {
  /// Creates a [ReferralStatsCard].
  const ReferralStatsCard({
    super.key,
    required this.stats,
    this.onTap,
  });

  /// The statistics to display.
  final ReferralStats stats;

  /// Optional callback invoked when the card is tapped (e.g. navigate to the
  /// detailed stats page).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatColumn(
                label: 'Total',
                value: stats.totalReferrals.toString(),
                icon: Icons.people_outline_rounded,
                color: theme.colorScheme.primary,
              ),
              _Divider(),
              _StatColumn(
                label: 'Pending',
                value: stats.pending.toString(),
                icon: Icons.hourglass_top_rounded,
                color: Colors.orange,
              ),
              _Divider(),
              _StatColumn(
                label: 'Earned',
                value: '${stats.currency} ${stats.totalEarnings.toStringAsFixed(0)}',
                icon: Icons.account_balance_wallet_outlined,
                color: Colors.green,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 6),
        Text(
          value,
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 1,
      color: Theme.of(context).dividerColor,
    );
  }
}
