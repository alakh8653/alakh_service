import 'package:flutter/material.dart';

import '../../domain/entities/referral_reward.dart';

/// A card widget that displays a single [ReferralReward] with its type, amount,
/// status, and a Claim button when the reward is available.
class RewardCard extends StatelessWidget {
  /// Creates a [RewardCard].
  const RewardCard({
    super.key,
    required this.reward,
    this.onClaim,
    this.isLoading = false,
  });

  /// The reward to display.
  final ReferralReward reward;

  /// Callback invoked when the user taps the Claim button.
  /// If `null`, no claim button is shown.
  final VoidCallback? onClaim;

  /// When `true`, shows a loading indicator on the claim button.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (iconData, accentColor) = _rewardTypeStyle(reward.type);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(iconData, color: accentColor, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reward.type.label,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${reward.currency} ${reward.amount.toStringAsFixed(0)}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: accentColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _StatusBadge(status: reward.status),
                ],
              ),
            ),
            if (reward.isAvailable && onClaim != null)
              _ClaimButton(onTap: onClaim!, isLoading: isLoading),
            if (reward.isClaimed)
              Icon(Icons.check_circle_rounded,
                  color: Colors.green, size: 28),
          ],
        ),
      ),
    );
  }

  (IconData, Color) _rewardTypeStyle(RewardType type) {
    switch (type) {
      case RewardType.cashback:
        return (Icons.account_balance_wallet_rounded, Colors.green);
      case RewardType.credit:
        return (Icons.stars_rounded, Colors.blue);
      case RewardType.discount:
        return (Icons.local_offer_rounded, Colors.orange);
    }
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final RewardStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      RewardStatus.available => ('Available', Colors.green),
      RewardStatus.processing => ('Processing', Colors.orange),
      RewardStatus.claimed => ('Claimed', Colors.blue),
      RewardStatus.expired => ('Expired', Colors.red),
    };

    return Text(
      label,
      style: TextStyle(
          color: color, fontSize: 12, fontWeight: FontWeight.w600),
    );
  }
}

class _ClaimButton extends StatelessWidget {
  const _ClaimButton({required this.onTap, required this.isLoading});

  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onTap,
      style: ElevatedButton.styleFrom(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text('Claim'),
    );
  }
}
