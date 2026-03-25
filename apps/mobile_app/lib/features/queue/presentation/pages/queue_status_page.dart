import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/queue_entry.dart';
import '../../domain/entities/queue_status.dart';
import '../bloc/queue_bloc.dart';
import '../bloc/queue_event.dart';
import '../bloc/queue_state.dart';
import '../widgets/live_position_tracker.dart';
import '../widgets/queue_position_card.dart';
import '../widgets/queue_status_badge.dart';
import '../widgets/wait_time_indicator.dart';

/// Live queue status page displayed after a user has joined a queue.
///
/// Uses [BlocListener] to react to status changes (e.g. showing a notification
/// when the user is called) and [BlocBuilder] to rebuild the UI with updated
/// position data.
class QueueStatusPage extends StatelessWidget {
  /// The initial queue entry obtained at join time.
  final QueueEntry entry;

  /// Creates a [QueueStatusPage].
  const QueueStatusPage({super.key, required this.entry});

  /// Named route for this page.
  static const routeName = '/queue/status';

  @override
  Widget build(BuildContext context) {
    return BlocListener<QueueBloc, QueueState>(
      listener: (context, state) {
        if (state is QueuePositionUpdated &&
            state.entry.status == QueueStatus.called) {
          _showCalledDialog(context);
        } else if (state is QueueCompleted) {
          _showCompletedDialog(context, state.entry);
        } else if (state is QueueError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Your Queue'),
          actions: [
            TextButton(
              onPressed: () => _confirmLeave(context),
              child: const Text(
                'Leave Queue',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
        body: BlocBuilder<QueueBloc, QueueState>(
          builder: (context, state) {
            final currentEntry = switch (state) {
              QueuePositionUpdated(:final entry) => entry,
              QueueJoined(:final entry) => entry,
              _ => entry,
            };

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: QueuePositionCard(
                      position: currentEntry.position,
                      label: currentEntry.status.label,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: WaitTimeIndicator(
                      totalMinutes:
                          currentEntry.estimatedWaitTime.inMinutes + 1,
                      elapsedMinutes: DateTime.now()
                          .difference(currentEntry.joinedAt)
                          .inMinutes
                          .clamp(
                            0,
                            currentEntry.estimatedWaitTime.inMinutes,
                          ),
                      size: 140,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Journey',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  LivePositionTracker(currentStatus: currentEntry.status),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Status'),
                      QueueStatusBadge(status: currentEntry.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Joined at'),
                      Text(
                        _formatTime(currentEntry.joinedAt),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showCalledDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("You've been called! 🔔"),
        content: const Text(
          "Please proceed to the counter now. You have a limited time to check in.",
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('On my way!'),
          ),
        ],
      ),
    );
  }

  void _showCompletedDialog(BuildContext context, QueueEntry finalisedEntry) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          finalisedEntry.status == QueueStatus.completed
              ? 'Service Completed ✅'
              : 'Queue Ended',
        ),
        content: Text(
          finalisedEntry.status == QueueStatus.completed
              ? 'Thank you for your visit!'
              : 'Your queue entry has ended (${finalisedEntry.status.label}).',
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context)
                ..pop()
                ..pop();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLeave(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Leave Queue?'),
        content: const Text(
          'Are you sure you want to leave? You will lose your current position.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<QueueBloc>().add(LeaveQueueEvent(entryId: entry.id));
      Navigator.of(context).pop();
    }
  }

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}
