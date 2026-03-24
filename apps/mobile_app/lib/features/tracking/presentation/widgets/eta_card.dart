import 'package:flutter/material.dart';

/// Card widget that displays the estimated time of arrival and distance.
class EtaCard extends StatelessWidget {
  /// The estimated time of arrival.
  final Duration eta;

  /// Distance to destination in kilometres.
  final double distanceKm;

  /// Creates an [EtaCard].
  const EtaCard({
    super.key,
    required this.eta,
    required this.distanceKm,
  });

  String _formatEta(Duration d) {
    if (d.inHours >= 1) {
      final h = d.inHours;
      final m = d.inMinutes.remainder(60);
      return '$h h ${m} min';
    }
    final m = d.inMinutes;
    if (m == 0) return 'Less than a minute';
    return '$m min';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            const Icon(Icons.access_time, color: Colors.blue, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ETA: ${_formatEta(eta)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${distanceKm.toStringAsFixed(1)} km away',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
