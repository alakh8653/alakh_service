import 'package:flutter/material.dart';

/// A large animated card that displays the user's current queue position.
///
/// Uses [AnimatedSwitcher] to smoothly transition between position numbers
/// as the value changes.
class QueuePositionCard extends StatelessWidget {
  /// The current 1-based queue position to display.
  final int position;

  /// Optional label shown below the position number.
  final String? label;

  /// Creates a [QueuePositionCard].
  const QueuePositionCard({
    super.key,
    required this.position,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Your Position',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: animation,
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: Text(
                '$position',
                // ValueKey forces AnimatedSwitcher to animate on change.
                key: ValueKey<int>(position),
                style: theme.textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                  fontSize: 80,
                ),
              ),
            ),
            if (label != null) ...[
              const SizedBox(height: 8),
              Text(
                label!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
