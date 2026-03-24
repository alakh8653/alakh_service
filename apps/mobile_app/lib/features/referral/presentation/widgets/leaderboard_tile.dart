import 'package:flutter/material.dart';

/// A leaderboard list tile that displays a user's rank position, display name,
/// and referral earnings.
///
/// The tile for the currently authenticated user is visually highlighted using
/// a tinted background.
class LeaderboardTile extends StatelessWidget {
  /// Creates a [LeaderboardTile].
  const LeaderboardTile({
    super.key,
    required this.rank,
    required this.name,
    required this.earnings,
    required this.currency,
    this.isCurrentUser = false,
  });

  /// Rank position on the leaderboard (1-based).
  final int rank;

  /// Display name of the user.
  final String name;

  /// Total referral earnings for this user.
  final double earnings;

  /// ISO 4217 currency code, e.g. `"INR"`.
  final String currency;

  /// Whether this tile represents the authenticated user.  When `true`, the
  /// tile is highlighted.
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final highlightColor = theme.colorScheme.primary.withOpacity(0.08);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isCurrentUser ? highlightColor : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isCurrentUser
            ? Border.all(
                color: theme.colorScheme.primary.withOpacity(0.4), width: 1.5)
            : null,
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: _RankBadge(rank: rank),
        title: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight:
                      isCurrentUser ? FontWeight.bold : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isCurrentUser) ...[
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'You',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        trailing: Text(
          '$currency ${earnings.toStringAsFixed(0)}',
          style: theme.textTheme.titleSmall?.copyWith(
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// Rank badge widget – top-3 ranks use gold/silver/bronze, others show the
/// numeric rank.
class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rank});

  final int rank;

  @override
  Widget build(BuildContext context) {
    if (rank <= 3) {
      final (emoji, color) = switch (rank) {
        1 => ('🥇', Colors.amber),
        2 => ('🥈', Colors.blueGrey),
        _ => ('🥉', Colors.brown),
      };
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(emoji, style: const TextStyle(fontSize: 20)),
      );
    }

    return CircleAvatar(
      radius: 18,
      backgroundColor:
          Theme.of(context).colorScheme.onSurface.withOpacity(0.08),
      child: Text(
        '$rank',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
