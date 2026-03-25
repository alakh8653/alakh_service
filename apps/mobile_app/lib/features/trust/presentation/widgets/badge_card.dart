import 'package:flutter/material.dart';
import '../../domain/entities/trust_badge.dart';

class BadgeCard extends StatelessWidget {
  final TrustBadge badge;

  const BadgeCard({super.key, required this.badge});

  Color _tierColor(BadgeTier tier) {
    switch (tier) {
      case BadgeTier.bronze: return const Color(0xFFCD7F32);
      case BadgeTier.silver: return const Color(0xFFC0C0C0);
      case BadgeTier.gold: return const Color(0xFFFFD700);
      case BadgeTier.platinum: return const Color(0xFFE5E4E2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tierColor = _tierColor(badge.tier);
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: tierColor.withOpacity(0.2),
                border: Border.all(color: tierColor, width: 2),
              ),
              child: Center(
                child: Text(badge.icon, style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              badge.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              badge.tier.name.toUpperCase(),
              style: TextStyle(
                  color: tierColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
