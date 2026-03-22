import 'package:flutter/material.dart';

/// A circular progress indicator with estimated wait-time text overlaid in the
/// centre.
///
/// The progress ring fills proportionally based on [elapsedMinutes] /
/// [totalMinutes].
class WaitTimeIndicator extends StatelessWidget {
  /// Total estimated wait duration in minutes.
  final int totalMinutes;

  /// Minutes already elapsed since joining the queue.
  final int elapsedMinutes;

  /// Diameter of the indicator in logical pixels.
  final double size;

  /// Creates a [WaitTimeIndicator].
  const WaitTimeIndicator({
    super.key,
    required this.totalMinutes,
    required this.elapsedMinutes,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remaining =
        (totalMinutes - elapsedMinutes).clamp(0, totalMinutes);
    final progress = totalMinutes > 0
        ? (elapsedMinutes / totalMinutes).clamp(0.0, 1.0)
        : 0.0;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 8,
              backgroundColor:
                  theme.colorScheme.primary.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$remaining',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              Text(
                'min',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
