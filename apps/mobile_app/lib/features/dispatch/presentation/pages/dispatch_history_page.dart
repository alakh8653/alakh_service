import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/dispatch_job.dart';
import '../../domain/entities/dispatch_status.dart';
import '../bloc/dispatch_bloc.dart';
import '../bloc/dispatch_event.dart';
import '../bloc/dispatch_state.dart';

/// Page showing the staff member's paginated history of past dispatch jobs.
class DispatchHistoryPage extends StatefulWidget {
  const DispatchHistoryPage({super.key});

  @override
  State<DispatchHistoryPage> createState() => _DispatchHistoryPageState();
}

class _DispatchHistoryPageState extends State<DispatchHistoryPage> {
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    context.read<DispatchBloc>().add(LoadHistoryEvent(page: _currentPage));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Job History')),
      body: BlocBuilder<DispatchBloc, DispatchState>(
        builder: (context, state) {
          if (state is DispatchLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is DispatchError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 12),
                  Text(state.message),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => context
                        .read<DispatchBloc>()
                        .add(LoadHistoryEvent(page: _currentPage)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is DispatchHistoryLoaded) {
            if (state.jobs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.history_outlined, size: 64, color: Theme.of(context).colorScheme.outline),
                    const SizedBox(height: 12),
                    Text('No job history yet.', style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
              );
            }
            return Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.jobs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final job = state.jobs[index];
                      return _HistoryJobCard(
                        job: job,
                        onTap: () => Navigator.of(context).pushNamed(
                          '/dispatch/details',
                          arguments: job,
                        ),
                      );
                    },
                  ),
                ),
                _PaginationBar(
                  currentPage: state.page,
                  hasNextPage: state.jobs.length >= 20,
                  onPrevious: state.page > 1
                      ? () {
                          setState(() => _currentPage = state.page - 1);
                          context
                              .read<DispatchBloc>()
                              .add(LoadHistoryEvent(page: _currentPage));
                        }
                      : null,
                  onNext: state.jobs.length >= 20
                      ? () {
                          setState(() => _currentPage = state.page + 1);
                          context
                              .read<DispatchBloc>()
                              .add(LoadHistoryEvent(page: _currentPage));
                        }
                      : null,
                ),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class _HistoryJobCard extends StatelessWidget {
  final DispatchJob job;
  final VoidCallback onTap;

  const _HistoryJobCard({required this.job, required this.onTap});

  Color _statusColor(BuildContext context, DispatchStatus status) {
    switch (status) {
      case DispatchStatus.completed:
        return Colors.green;
      case DispatchStatus.cancelled:
        return Theme.of(context).colorScheme.error;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 56,
                decoration: BoxDecoration(
                  color: _statusColor(context, job.status),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Job #${job.id.substring(0, 8)}',
                          style: theme.textTheme.titleSmall,
                        ),
                        Text(
                          '₹${job.fare.toStringAsFixed(0)}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      job.pickupLocation.address,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor(context, job.status).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        job.status.label,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: _statusColor(context, job.status),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaginationBar extends StatelessWidget {
  final int currentPage;
  final bool hasNextPage;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const _PaginationBar({
    required this.currentPage,
    required this.hasNextPage,
    this.onPrevious,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: onPrevious,
            icon: const Icon(Icons.chevron_left),
            label: const Text('Previous'),
          ),
          Text('Page $currentPage', style: Theme.of(context).textTheme.bodyMedium),
          TextButton.icon(
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right),
            label: const Text('Next'),
          ),
        ],
      ),
    );
  }
}
