import 'package:flutter/material.dart';

import '../../domain/entities/referral.dart';
import '../../domain/entities/referral_status.dart';

/// A list tile that displays a single [Referral] entry with the referee's
/// name, the current status (as a colour-coded chip), and the creation date.
class ReferralListItem extends StatelessWidget {
  /// Creates a [ReferralListItem].
  const ReferralListItem({
    super.key,
    required this.referral,
    this.onTap,
  });

  /// The referral to display.
  final Referral referral;

  /// Optional callback invoked when the tile is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _statusColor(referral.status);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: ListTile(
        onTap: onTap,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.15),
          child: Text(
            referral.refereeName.isNotEmpty
                ? referral.refereeName[0].toUpperCase()
                : '?',
            style: TextStyle(
                color: statusColor, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          referral.refereeName,
          style: theme.textTheme.titleSmall
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          _formatDate(referral.createdAt),
          style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.55)),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _StatusChip(status: referral.status, color: statusColor),
            if (referral.rewardAmount > 0) ...[
              const SizedBox(height: 4),
              Text(
                '${referral.currency} ${referral.rewardAmount.toStringAsFixed(0)}',
                style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.green, fontWeight: FontWeight.w600),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _statusColor(ReferralStatus status) {
    switch (status) {
      case ReferralStatus.pending:
        return Colors.orange;
      case ReferralStatus.registered:
        return Colors.blue;
      case ReferralStatus.firstBookingCompleted:
        return Colors.teal;
      case ReferralStatus.rewardClaimed:
        return Colors.green;
      case ReferralStatus.expired:
        return Colors.red;
    }
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';
}

/// Small status chip rendered inside [ReferralListItem].
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, required this.color});

  final ReferralStatus status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status.label,
        style: TextStyle(
            color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
