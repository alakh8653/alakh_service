import 'package:flutter/material.dart';

import '../../domain/entities/referral_stats.dart';

/// A visual progress bar that communicates the user's advancement toward their
/// next referral tier.
///
/// Shows the current tier name, completed-referral count, and the target
/// threshold.  When the user is at the highest tier, a completion message is
/// displayed instead.
class ReferralTierProgress extends StatelessWidget {
  /// Creates a [ReferralTierProgress] widget.
  const ReferralTierProgress({
    super.key,
    required this.stats,
  });

  /// The stats object containing tier and progress information.
  final ReferralStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMaxTier = stats.nextTierThreshold == null;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.emoji_events_rounded,
                        color: Colors.amber, size: 22),
                    const SizedBox(width: 6),
                    Text(
                      stats.currentTier,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                if (!isMaxTier)
                  Text(
                    '${stats.completed} / ${stats.nextTierThreshold}',
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (isMaxTier) ...[
              Row(
                children: [
                  const Icon(Icons.verified_rounded,
                      color: Colors.amber, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'You\'ve reached the highest tier! 🎉',
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.amber,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ] else ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: stats.tierProgressRatio,
                  minHeight: 10,
                  backgroundColor:
                      theme.colorScheme.primary.withOpacity(0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${stats.remainingForNextTier} more referrals to next tier',
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
