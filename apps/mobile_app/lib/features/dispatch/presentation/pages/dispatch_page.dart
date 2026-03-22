import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/dispatch_bloc.dart';
import '../bloc/dispatch_event.dart';
import '../bloc/dispatch_state.dart';
import '../widgets/dispatch_action_button.dart';
import '../widgets/dispatch_status_stepper.dart';
import '../widgets/customer_info_card.dart';
import '../widgets/eta_display.dart';

/// Root dispatch page. Shows the active job status or an idle placeholder
/// when the staff member has no active job.
class DispatchPage extends StatefulWidget {
  /// The ID of the logged-in staff member used for watching live updates.
  final String staffId;

  const DispatchPage({super.key, required this.staffId});

  @override
  State<DispatchPage> createState() => _DispatchPageState();
}

class _DispatchPageState extends State<DispatchPage> {
  @override
  void initState() {
    super.initState();
    context.read<DispatchBloc>()
      ..add(const LoadActiveJobEvent())
      ..add(WatchUpdatesEvent(staffId: widget.staffId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispatch'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_outlined),
            tooltip: 'Job History',
            onPressed: () => Navigator.of(context).pushNamed('/dispatch/history'),
          ),
        ],
      ),
      body: BlocConsumer<DispatchBloc, DispatchState>(
        listener: (context, state) {
          if (state is DispatchError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
          if (state is JobAssignedState) {
            Navigator.of(context).pushNamed(
              '/dispatch/assignment',
              arguments: state.assignment,
            );
          }
          if (state is EnRouteState) {
            Navigator.of(context).pushNamed(
              '/dispatch/navigation',
              arguments: state,
            );
          }
        },
        builder: (context, state) {
          if (state is DispatchLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is DispatchIdle) {
            return const _IdlePlaceholder();
          }
          if (state is JobAcceptedState || state is ArrivedState || state is JobInProgressState) {
            return _ActiveJobView(state: state);
          }
          if (state is JobCompletedState) {
            return _CompletedJobView(job: state.job);
          }
          return const _IdlePlaceholder();
        },
      ),
    );
  }
}

class _IdlePlaceholder extends StatelessWidget {
  const _IdlePlaceholder();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 80,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No Active Jobs',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'New assignments will appear here automatically.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveJobView extends StatelessWidget {
  final DispatchState state;

  const _ActiveJobView({required this.state});

  @override
  Widget build(BuildContext context) {
    final job = state is JobAcceptedState
        ? (state as JobAcceptedState).job
        : state is ArrivedState
            ? (state as ArrivedState).job
            : (state as JobInProgressState).job;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DispatchStatusStepper(currentStatus: job.status),
          const SizedBox(height: 16),
          CustomerInfoCard(
            customerName: 'Customer',
            customerPhone: '',
            serviceType: 'Service',
          ),
          const SizedBox(height: 16),
          DispatchActionButton(
            status: job.status,
            jobId: job.id,
            onAction: (nextStatus) {
              context.read<DispatchBloc>().add(
                    UpdateStatusEvent(jobId: job.id, status: nextStatus),
                  );
            },
          ),
        ],
      ),
    );
  }
}

class _CompletedJobView extends StatelessWidget {
  final dynamic job;

  const _CompletedJobView({required this.job});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text('Job Completed!', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => context.read<DispatchBloc>().add(const LoadActiveJobEvent()),
            child: const Text('Back to Dispatch'),
          ),
        ],
      ),
    );
  }
}
