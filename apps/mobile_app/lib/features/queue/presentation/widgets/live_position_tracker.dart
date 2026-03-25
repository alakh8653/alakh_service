import 'package:flutter/material.dart';

import '../../domain/entities/queue_status.dart';

/// A horizontal step-progress tracker that visualises a queue entry's
/// lifecycle journey.
///
/// Renders each [QueueStatus] phase as a labelled step separated by a
/// [LinearProgressIndicator].  Completed steps are highlighted; the current
/// step is emphasised.
class LivePositionTracker extends StatelessWidget {
  /// The current status of the queue entry.
  final QueueStatus currentStatus;

  /// Creates a [LivePositionTracker].
  const LivePositionTracker({super.key, required this.currentStatus});

  // Ordered list of active-phase statuses shown in the tracker.
  static const List<QueueStatus> _phases = [
    QueueStatus.waiting,
    QueueStatus.called,
    QueueStatus.serving,
    QueueStatus.completed,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentIndex = _phases.indexOf(currentStatus);

    return Row(
      children: List.generate(_phases.length * 2 - 1, (index) {
        // Even indices are step indicators; odd indices are connectors.
        if (index.isOdd) {
          final leftPhaseIndex = index ~/ 2;
          final done = leftPhaseIndex < currentIndex;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: LinearProgressIndicator(
                value: done ? 1.0 : 0.0,
                minHeight: 4,
                backgroundColor:
                    theme.colorScheme.primary.withOpacity(0.15),
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
            ),
          );
        }

        final phaseIndex = index ~/ 2;
        final phase = _phases[phaseIndex];
        final isDone = phaseIndex < currentIndex;
        final isCurrent = phaseIndex == currentIndex;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isCurrent ? 36 : 28,
              height: isCurrent ? 36 : 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone || isCurrent
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceVariant,
                border: isCurrent
                    ? Border.all(
                        color: theme.colorScheme.primary,
                        width: 2,
                      )
                    : null,
              ),
              child: Center(
                child: isDone
                    ? Icon(
                        Icons.check,
                        size: 16,
                        color: theme.colorScheme.onPrimary,
                      )
                    : Icon(
                        _iconForPhase(phase),
                        size: isCurrent ? 18 : 14,
                        color: isCurrent
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              phase.label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isCurrent
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.5),
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        );
      }),
    );
  }

  IconData _iconForPhase(QueueStatus phase) {
    switch (phase) {
      case QueueStatus.waiting:
        return Icons.hourglass_empty;
      case QueueStatus.called:
        return Icons.notifications_active;
      case QueueStatus.serving:
        return Icons.store;
      case QueueStatus.completed:
        return Icons.done_all;
      default:
        return Icons.circle_outlined;
    }
  }
}
