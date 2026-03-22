import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/queue_bloc.dart';
import '../bloc/queue_event.dart';
import '../bloc/queue_state.dart';
import '../widgets/queue_info_tile.dart';
import '../widgets/queue_position_card.dart';
import '../widgets/queue_status_badge.dart';
import '../widgets/wait_time_indicator.dart';
import 'join_queue_page.dart';
import 'queue_status_page.dart';

/// Main queue page that routes between the lobby view, an active queue view,
/// and error/loading states.
///
/// Provide a [shopId] to pre-load the queue status for that shop.
class QueuePage extends StatelessWidget {
  /// The shop whose queue information to display.
  final String shopId;

  /// Creates a [QueuePage].
  const QueuePage({super.key, required this.shopId});

  /// Named route for this page.
  static const routeName = '/queue';

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<QueueBloc, QueueState>(
      listener: (context, state) {
        if (state is QueueJoined) {
          // Navigate to the live status page after joining.
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => BlocProvider.value(
                value: context.read<QueueBloc>(),
                child: QueueStatusPage(entry: state.entry),
              ),
            ),
          );
        } else if (state is QueueError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Queue'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
                onPressed: () => context
                    .read<QueueBloc>()
                    .add(RefreshQueueEvent(shopId: shopId)),
              ),
            ],
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, QueueState state) {
    if (state is QueueLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is QueueStatusLoaded) {
      final queue = state.queue;
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            QueueInfoTile(
              queueName: queue.name,
              currentSize: queue.currentSize,
              avgWaitMinutes: queue.averageWaitTime.inMinutes,
              isActive: queue.isActive,
            ),
            const SizedBox(height: 24),
            Center(
              child: WaitTimeIndicator(
                totalMinutes: queue.averageWaitTime.inMinutes,
                elapsedMinutes: 0,
                size: 140,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: queue.hasCapacity
                  ? () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => BlocProvider.value(
                            value: context.read<QueueBloc>(),
                            child: JoinQueuePage(shopId: shopId),
                          ),
                        ),
                      )
                  : null,
              icon: const Icon(Icons.queue),
              label: Text(queue.hasCapacity ? 'Join Queue' : 'Queue Full'),
            ),
          ],
        ),
      );
    }

    if (state is QueuePositionUpdated || state is QueueJoined) {
      final entry = state is QueuePositionUpdated
          ? state.entry
          : (state as QueueJoined).entry;
      return Center(
        child: QueuePositionCard(
          position: entry.position,
          label: 'Currently waiting',
        ),
      );
    }

    if (state is QueueError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 8),
            Text(state.message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context
                  .read<QueueBloc>()
                  .add(LoadQueueStatusEvent(shopId: shopId)),
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    // QueueInitial – prompt the user to load the queue.
    return Center(
      child: ElevatedButton(
        onPressed: () => context
            .read<QueueBloc>()
            .add(LoadQueueStatusEvent(shopId: shopId)),
        child: const Text('Load Queue'),
      ),
    );
  }
}
