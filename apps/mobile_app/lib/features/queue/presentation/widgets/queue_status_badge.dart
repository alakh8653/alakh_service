import 'package:flutter/material.dart';

import '../../domain/entities/queue_status.dart';

/// A coloured [Chip] that visually represents a [QueueStatus].
class QueueStatusBadge extends StatelessWidget {
  /// The queue status to display.
  final QueueStatus status;

  /// Creates a [QueueStatusBadge].
  const QueueStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (bg, fg) = _colorsForStatus(theme, status);

    return Chip(
      label: Text(
        status.label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: bg,
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      visualDensity: VisualDensity.compact,
      avatar: Icon(_iconForStatus(status), size: 14, color: fg),
    );
  }

  /// Returns a (background, foreground) colour pair for the given [status].
  (Color, Color) _colorsForStatus(ThemeData theme, QueueStatus status) {
    switch (status) {
      case QueueStatus.waiting:
        return (
          theme.colorScheme.primaryContainer,
          theme.colorScheme.onPrimaryContainer,
        );
      case QueueStatus.called:
        return (
          theme.colorScheme.tertiaryContainer,
          theme.colorScheme.onTertiaryContainer,
        );
      case QueueStatus.serving:
        return (Colors.green.shade100, Colors.green.shade800);
      case QueueStatus.completed:
        return (
          theme.colorScheme.surfaceVariant,
          theme.colorScheme.onSurfaceVariant,
        );
      case QueueStatus.cancelled:
        return (
          theme.colorScheme.errorContainer,
          theme.colorScheme.onErrorContainer,
        );
      case QueueStatus.noShow:
        return (Colors.orange.shade100, Colors.orange.shade800);
    }
  }

  /// Returns an icon suited to the [status].
  IconData _iconForStatus(QueueStatus status) {
    switch (status) {
      case QueueStatus.waiting:
        return Icons.hourglass_empty;
      case QueueStatus.called:
        return Icons.notifications_active;
      case QueueStatus.serving:
        return Icons.check_circle_outline;
      case QueueStatus.completed:
        return Icons.done_all;
      case QueueStatus.cancelled:
        return Icons.cancel_outlined;
      case QueueStatus.noShow:
        return Icons.warning_amber_outlined;
    }
  }
}
