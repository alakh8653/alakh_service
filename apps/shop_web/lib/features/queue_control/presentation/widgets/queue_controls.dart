import 'package:flutter/material.dart';
import 'package:shop_web/features/queue_control/domain/entities/queue_settings.dart';
import 'package:shop_web/shared/shared.dart';

/// Primary control toolbar for queue management actions.
///
/// Provides "Call Next", pause/resume toggle, and a settings shortcut.
class QueueControls extends StatelessWidget {
  const QueueControls({
    super.key,
    required this.settings,
    required this.onPause,
    required this.onResume,
    required this.onCallNext,
    required this.onOpenSettings,
    this.isActionInProgress = false,
  });

  final QueueSettings settings;

  /// Called with the user-entered pause reason.
  final void Function(String reason) onPause;
  final VoidCallback onResume;
  final VoidCallback onCallNext;
  final VoidCallback onOpenSettings;

  /// Disables buttons while an async action is in flight.
  final bool isActionInProgress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPaused = settings.isPaused;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPaused ? Colors.orange.shade300 : Colors.transparent,
          width: isPaused ? 1.5 : 0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Status indicator
          _QueueStatusChip(isActive: settings.isActive),
          if (isPaused && settings.pauseReason != null) ...[
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Paused: ${settings.pauseReason}',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: Colors.orange[800]),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ] else
            const Spacer(),

          // Call Next (primary action)
          FilledButton.icon(
            onPressed:
                isActionInProgress || isPaused ? null : onCallNext,
            icon: const Icon(Icons.call_rounded, size: 18),
            label: const Text('Call Next'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              textStyle: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 10),

          // Pause / Resume toggle
          if (isPaused)
            OutlinedButton.icon(
              onPressed: isActionInProgress ? null : onResume,
              icon: const Icon(Icons.play_arrow_rounded, size: 18),
              label: const Text('Resume'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green.shade700,
                side: BorderSide(color: Colors.green.shade400),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            )
          else
            OutlinedButton.icon(
              onPressed: isActionInProgress
                  ? null
                  : () => _showPauseDialog(context),
              icon: const Icon(Icons.pause_rounded, size: 18),
              label: const Text('Pause'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange.shade700,
                side: BorderSide(color: Colors.orange.shade400),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          const SizedBox(width: 8),

          // Settings icon
          IconButton(
            tooltip: 'Queue Settings',
            onPressed: onOpenSettings,
            icon: const Icon(Icons.settings_outlined),
            color: Colors.grey[600],
          ),
        ],
      ),
    );
  }

  Future<void> _showPauseDialog(BuildContext context) async {
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pause Queue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Provide a reason for pausing the queue:'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'e.g. Short break, Technical issue…',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Pause'),
          ),
        ],
      ),
    );

    if (confirmed == true && reasonController.text.trim().isNotEmpty) {
      onPause(reasonController.text.trim());
    }
    reasonController.dispose();
  }
}

/// Small chip indicating whether the queue is active or paused.
class _QueueStatusChip extends StatelessWidget {
  const _QueueStatusChip({required this.isActive});
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              isActive ? Colors.green.shade300 : Colors.orange.shade300,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive ? Colors.green.shade600 : Colors.orange.shade700,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isActive ? 'Queue Active' : 'Queue Paused',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive
                  ? Colors.green.shade700
                  : Colors.orange.shade800,
            ),
          ),
        ],
      ),
    );
  }
}
