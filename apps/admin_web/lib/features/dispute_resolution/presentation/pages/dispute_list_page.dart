import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:admin_web/shared/shared.dart';
import 'package:admin_web/features/dispute_resolution/domain/entities/dispute_entity.dart';
import 'package:admin_web/features/dispute_resolution/presentation/bloc/dispute_bloc.dart';
import 'package:admin_web/features/dispute_resolution/presentation/bloc/dispute_event.dart';
import 'package:admin_web/features/dispute_resolution/presentation/bloc/dispute_state.dart';
import 'package:admin_web/features/dispute_resolution/presentation/widgets/dispute_priority_badge.dart';

class DisputeListPage extends StatelessWidget {
  final String? detailId;

  const DisputeListPage({super.key, this.detailId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DisputeBloc>(
      create: (_) =>
          GetIt.instance<DisputeBloc>()..add(const LoadDisputes()),
      child: const _DisputeListView(),
    );
  }
}

class _DisputeListView extends StatefulWidget {
  const _DisputeListView();

  @override
  State<_DisputeListView> createState() => _DisputeListViewState();
}

class _DisputeListViewState extends State<_DisputeListView> {
  DisputeStatus? _statusFilter;
  DisputePriority? _priorityFilter;

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Dispute Resolution',
      body: BlocConsumer<DisputeBloc, DisputeState>(
        listener: (context, state) {
          if (state is DisputeOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            context.read<DisputeBloc>().add(const LoadDisputes());
          } else if (state is DisputeError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AdminPageHeader(
                title: 'Dispute Resolution',
                subtitle: 'Manage customer and shop disputes',
              ),
              const SizedBox(height: 16),
              if (state is DisputesLoaded) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _SummaryCards(state: state),
                ),
                const SizedBox(height: 16),
              ],
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: AdminSearchField(
                        hintText: 'Search by ticket, customer, shop...',
                        onChanged: (q) => context.read<DisputeBloc>().add(
                              FilterDisputes(
                                search: q,
                                status: _statusFilter,
                                priority: _priorityFilter,
                              ),
                            ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _StatusFilter(
                      value: _statusFilter,
                      onChanged: (v) {
                        setState(() => _statusFilter = v);
                        context.read<DisputeBloc>().add(
                              FilterDisputes(
                                status: v,
                                priority: _priorityFilter,
                              ),
                            );
                      },
                    ),
                    const SizedBox(width: 12),
                    _PriorityFilter(
                      value: _priorityFilter,
                      onChanged: (v) {
                        setState(() => _priorityFilter = v);
                        context.read<DisputeBloc>().add(
                              FilterDisputes(
                                status: _statusFilter,
                                priority: v,
                              ),
                            );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildContent(context, state),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, DisputeState state) {
    if (state is DisputesLoading) return const AdminLoadingSkeleton();
    if (state is DisputeError) {
      return AdminEmptyState(
        icon: Icons.error_outline,
        message: 'Error',
        message: state.message,
        description: 'Failed to load disputes',
        onAction: () => context.read<DisputeBloc>().add(const LoadDisputes()),
      );
    }
    if (state is DisputesLoaded) {
      if (state.disputes.isEmpty) {
        return const AdminEmptyState(
          icon: Icons.support_agent_outlined,
          title: 'No Disputes',
          message: 'No disputes found for the current filters',
        );
      }
      return _DisputesTable(
        disputes: state.disputes,
        onTap: (d) => context.push('/disputes/${d.id}'),
      );
    }
    return const SizedBox.shrink();
  }
}

class _SummaryCards extends StatelessWidget {
  final DisputesLoaded state;

  const _SummaryCards({required this.state});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: MetricCard(
            title: 'Open',
            value: state.openCount.toString(),
            icon: Icons.inbox,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: MetricCard(
            title: 'In Progress',
            value: state.inProgressCount.toString(),
            icon: Icons.pending_actions,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: MetricCard(
            title: 'Escalated',
            value: state.escalatedCount.toString(),
            icon: Icons.warning,
            color: Colors.red,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: MetricCard(
            title: 'Resolved',
            value: state.resolvedCount.toString(),
            icon: Icons.check_circle,
            color: Colors.green,
          ),
        ),
      ],
    );
  }
}

class _StatusFilter extends StatelessWidget {
  final DisputeStatus? value;
  final ValueChanged<DisputeStatus?> onChanged;

  const _StatusFilter({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButton<DisputeStatus?>(
          value: value,
          hint: const Text('Status'),
          items: [
            const DropdownMenuItem(value: null, child: Text('All Status')),
            ...DisputeStatus.values.map((s) => DropdownMenuItem(
                  value: s,
                  child: Text(s.displayName),
                )),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _PriorityFilter extends StatelessWidget {
  final DisputePriority? value;
  final ValueChanged<DisputePriority?> onChanged;

  const _PriorityFilter({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButton<DisputePriority?>(
          value: value,
          hint: const Text('Priority'),
          items: [
            const DropdownMenuItem(value: null, child: Text('All Priority')),
            ...DisputePriority.values.map((p) => DropdownMenuItem(
                  value: p,
                  child: Text(p.displayName),
                )),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _DisputesTable extends StatelessWidget {
  final List<DisputeEntity> disputes;
  final ValueChanged<DisputeEntity> onTap;

  const _DisputesTable({required this.disputes, required this.onTap});

  Color _statusColor(DisputeStatus status) {
    switch (status) {
      case DisputeStatus.open:
        return Colors.blue;
      case DisputeStatus.inProgress:
        return Colors.orange;
      case DisputeStatus.pendingCustomer:
        return Colors.purple;
      case DisputeStatus.pendingShop:
        return Colors.teal;
      case DisputeStatus.resolved:
        return Colors.green;
      case DisputeStatus.closed:
        return Colors.grey;
      case DisputeStatus.escalated:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminDataTable(
      columns: const [
        DataColumn(label: Text('Ticket #')),
        DataColumn(label: Text('Title')),
        DataColumn(label: Text('Customer')),
        DataColumn(label: Text('Shop')),
        DataColumn(label: Text('Type')),
        DataColumn(label: Text('Priority')),
        DataColumn(label: Text('Status')),
        DataColumn(label: Text('Created')),
        DataColumn(label: Text('Actions')),
      ],
      rows: disputes.map((d) {
        return DataRow(
          onSelectChanged: (_) => onTap(d),
          cells: [
            DataCell(Text(
              d.ticketNumber,
              style: const TextStyle(
                  fontFamily: 'monospace', fontWeight: FontWeight.w600),
            )),
            DataCell(
              SizedBox(
                width: 180,
                child: Text(
                  d.title,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            DataCell(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(d.customerName),
                  Text(
                    d.customerPhone,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),
            DataCell(Text(d.shopName)),
            DataCell(Text(d.type.displayName)),
            DataCell(DisputePriorityBadge(priority: d.priority)),
            DataCell(
              AdminStatusBadge(
                label: d.status.displayName,
                color: _statusColor(d.status),
              ),
            ),
            DataCell(Text(_formatDate(d.createdAt))),
            DataCell(
              IconButton(
                icon: const Icon(Icons.open_in_new, size: 18),
                tooltip: 'View Details',
                onPressed: () => onTap(d),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.day}/${date.month}/${date.year}';
}
