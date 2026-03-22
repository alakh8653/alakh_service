import 'package:flutter/material.dart';

/// A [ListTile] that displays high-level queue information.
///
/// Shows the queue name, the current number of people waiting, and the
/// average wait time.
class QueueInfoTile extends StatelessWidget {
  /// Display name of the queue / service.
  final String queueName;

  /// Number of people currently in the queue.
  final int currentSize;

  /// Average estimated wait time in minutes.
  final int avgWaitMinutes;

  /// Whether the queue is currently active and accepting new entries.
  final bool isActive;

  /// Optional tap callback.
  final VoidCallback? onTap;

  /// Creates a [QueueInfoTile].
  const QueueInfoTile({
    super.key,
    required this.queueName,
    required this.currentSize,
    required this.avgWaitMinutes,
    required this.isActive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: isActive
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceVariant,
        child: Icon(
          Icons.queue,
          color: isActive
              ? theme.colorScheme.onPrimaryContainer
              : theme.colorScheme.onSurfaceVariant,
        ),
      ),
      title: Text(
        queueName,
        style: theme.textTheme.titleMedium,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '$currentSize waiting • ~$avgWaitMinutes min wait',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      trailing: isActive
          ? Icon(Icons.chevron_right, color: theme.colorScheme.primary)
          : Chip(
              label: const Text('Closed'),
              backgroundColor: theme.colorScheme.errorContainer,
              labelStyle: TextStyle(
                color: theme.colorScheme.onErrorContainer,
                fontSize: 11,
              ),
              padding: EdgeInsets.zero,
            ),
    );
  }
}
