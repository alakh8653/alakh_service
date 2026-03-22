import 'package:flutter/material.dart';

/// Displays route distance and duration summary.
class RouteInfoWidget extends StatelessWidget {
  /// Distance to destination in kilometres.
  final double distanceKm;

  /// Estimated duration. Null when not yet available.
  final Duration? eta;

  /// Creates a [RouteInfoWidget].
  const RouteInfoWidget({
    super.key,
    required this.distanceKm,
    this.eta,
  });

  String _formatDuration(Duration d) {
    if (d.inHours >= 1) {
      return '${d.inHours} h ${d.inMinutes.remainder(60)} min';
    }
    return '${d.inMinutes} min';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          children: [
            const Icon(Icons.straighten, size: 18, color: Colors.blueGrey),
            const SizedBox(width: 4),
            Text(
              '${distanceKm.toStringAsFixed(1)} km',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        if (eta != null)
          Row(
            children: [
              const Icon(Icons.timer_outlined,
                  size: 18, color: Colors.blueGrey),
              const SizedBox(width: 4),
              Text(
                _formatDuration(eta!),
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
      ],
    );
  }
}
