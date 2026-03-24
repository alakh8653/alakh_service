import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_web/features/queue_control/domain/entities/queue_settings.dart';
import 'package:shop_web/features/queue_control/presentation/bloc/queue_control_bloc.dart';
import 'package:shop_web/features/queue_control/presentation/bloc/queue_control_event.dart';
import 'package:shop_web/features/queue_control/presentation/bloc/queue_control_state.dart';
import 'package:shop_web/features/queue_control/presentation/widgets/queue_controls.dart';
import 'package:shop_web/features/queue_control/presentation/widgets/queue_list.dart';
import 'package:shop_web/features/queue_control/presentation/widgets/queue_stats_bar.dart';
import 'package:shop_web/shared/shared.dart';

/// Main page for the Queue Management feature.
///
/// Displays live queue stats, queue controls (call next / pause / settings),
/// and the reorderable list of queue entries. Handles loading, empty, and
/// error states.
class QueueControlPage extends StatefulWidget {
  const QueueControlPage({super.key});

  static const routeName = '/queue-control';

  @override
  State<QueueControlPage> createState() => _QueueControlPageState();
}

class _QueueControlPageState extends State<QueueControlPage> {
  @override
  void initState() {
    super.initState();
    context.read<QueueControlBloc>().add(const LoadQueue());
  }

  // ---------------------------------------------------------------------------
  // Event dispatchers
  // ---------------------------------------------------------------------------

  void _onCallNext(String id) =>
      context.read<QueueControlBloc>().add(CallNextInQueue(preferredId: id));

  void _onCallNextFirst() =>
      context.read<QueueControlBloc>().add(const CallNextInQueue());

  void _onRemove(String id) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => ConfirmationDialog(
        title: 'Remove from Queue',
        message:
            'Are you sure you want to remove this customer from the queue?',
        confirmLabel: 'Remove',
        confirmColor: Colors.red,
        onConfirm: () {
          context.read<QueueControlBloc>().add(RemoveFromQueue(id));
        },
      ),
    );
  }

  void _onReorder(int oldIndex, int newIndex) =>
      context.read<QueueControlBloc>().add(
            ReorderQueue(oldIndex: oldIndex, newIndex: newIndex),
          );

  void _onPause(String reason) =>
      context.read<QueueControlBloc>().add(PauseQueue(reason));

  void _onResume() =>
      context.read<QueueControlBloc>().add(const ResumeQueue());

  void _onOpenSettings(QueueSettings current) {
    showDialog<void>(
      context: context,
      builder: (ctx) => _QueueSettingsDialog(
        settings: current,
        onSave: (updated) {
          context
              .read<QueueControlBloc>()
              .add(UpdateQueueSettings(updated));
        },
      ),
    );
  }

  void _onRetry() =>
      context.read<QueueControlBloc>().add(const LoadQueue());

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: BlocBuilder<QueueControlBloc, QueueControlState>(
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: PageHeader(
                    title: 'Queue Management',
                    subtitle: 'Manage your live service queue in real time.',
                    actions: [
                      IconButton(
                        tooltip: 'Refresh',
                        icon: const Icon(Icons.refresh_rounded),
                        onPressed: () => context
                            .read<QueueControlBloc>()
                            .add(const RefreshQueue()),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(child: _buildBody(state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(QueueControlState state) {
    if (state is QueueControlLoading) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: LoadingTable(),
      );
    }

    if (state is QueueControlError &&
        state is! QueueControlLoaded) {
      return _ErrorView(message: state.message, onRetry: _onRetry);
    }

    if (state is QueueControlLoaded) {
      final isInProgress = state is QueueActionInProgress;

      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Stats
            QueueStatsBar(
              queueItems: state.queueItems,
              settings: state.settings,
            ),
            const SizedBox(height: 20),

            // Controls
            QueueControls(
              settings: state.settings,
              onPause: _onPause,
              onResume: _onResume,
              onCallNext: _onCallNextFirst,
              onOpenSettings: () => _onOpenSettings(state.settings),
              isActionInProgress: isInProgress,
            ),
            const SizedBox(height: 24),

            // Error banner (action-level error on top of loaded data)
            if (state is QueueControlError) ...[
              _ErrorBanner(message: (state as QueueControlError).message),
              const SizedBox(height: 16),
            ],

            // Queue list or empty state
            if (state.queueItems.isEmpty)
              const EmptyTableState(
                icon: Icons.people_outline_rounded,
                message: 'No customers are currently in the queue.',
              )
            else
              QueueList(
                items: state.queueItems,
                onReorder: _onReorder,
                onCallNext: _onCallNext,
                onRemove: _onRemove,
                currentlyServingId: state.currentlyServing?.id,
              ),
          ],
        ),
      );
    }

    // QueueControlInitial – nothing to show yet
    return const SizedBox.shrink();
  }
}

// ---------------------------------------------------------------------------
// Error widgets
// ---------------------------------------------------------------------------

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 56, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded,
              color: Colors.red.shade600, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.red.shade700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Settings Dialog
// ---------------------------------------------------------------------------

class _QueueSettingsDialog extends StatefulWidget {
  const _QueueSettingsDialog({
    required this.settings,
    required this.onSave,
  });

  final QueueSettings settings;
  final void Function(QueueSettings) onSave;

  @override
  State<_QueueSettingsDialog> createState() => _QueueSettingsDialogState();
}

class _QueueSettingsDialogState extends State<_QueueSettingsDialog> {
  late int _maxQueueSize;
  late int _avgServiceTime;
  late bool _autoAssignStaff;
  late bool _allowOnlineJoining;

  @override
  void initState() {
    super.initState();
    _maxQueueSize = widget.settings.maxQueueSize;
    _avgServiceTime = widget.settings.avgServiceTimeMinutes;
    _autoAssignStaff = widget.settings.autoAssignStaff;
    _allowOnlineJoining = widget.settings.allowOnlineJoining;
  }

  void _save() {
    widget.onSave(widget.settings.copyWith(
      maxQueueSize: _maxQueueSize,
      avgServiceTimeMinutes: _avgServiceTime,
      autoAssignStaff: _autoAssignStaff,
      allowOnlineJoining: _allowOnlineJoining,
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Queue Settings'),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _NumberField(
              label: 'Max Queue Size',
              value: _maxQueueSize,
              min: 1,
              max: 500,
              onChanged: (v) => setState(() => _maxQueueSize = v),
            ),
            const SizedBox(height: 16),
            _NumberField(
              label: 'Avg. Service Time (minutes)',
              value: _avgServiceTime,
              min: 1,
              max: 180,
              onChanged: (v) => setState(() => _avgServiceTime = v),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Auto-Assign Staff'),
              value: _autoAssignStaff,
              onChanged: (v) => setState(() => _autoAssignStaff = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Allow Online Joining'),
              value: _allowOnlineJoining,
              onChanged: (v) => setState(() => _allowOnlineJoining = v),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final void Function(int) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        const SizedBox(width: 12),
        SizedBox(
          width: 80,
          child: TextFormField(
            initialValue: value.toString(),
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            ),
            onChanged: (raw) {
              final parsed = int.tryParse(raw);
              if (parsed != null && parsed >= min && parsed <= max) {
                onChanged(parsed);
              }
            },
          ),
        ),
      ],
    );
  }
}
