import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:admin_web/shared/shared.dart';
import 'package:admin_web/features/dispute_resolution/domain/entities/dispute_entity.dart';
import 'package:admin_web/features/dispute_resolution/presentation/bloc/dispute_bloc.dart';
import 'package:admin_web/features/dispute_resolution/presentation/bloc/dispute_event.dart';
import 'package:admin_web/features/dispute_resolution/presentation/bloc/dispute_state.dart';
import 'package:admin_web/features/dispute_resolution/presentation/widgets/dispute_priority_badge.dart';
import 'package:admin_web/features/dispute_resolution/presentation/widgets/resolution_form.dart';

class DisputeDetailPage extends StatelessWidget {
  final String disputeId;

  const DisputeDetailPage({super.key, required this.disputeId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DisputeBloc>(
      create: (_) => GetIt.instance<DisputeBloc>()
        ..add(LoadDisputeById(disputeId)),
      child: _DisputeDetailView(disputeId: disputeId),
    );
  }
}

class _DisputeDetailView extends StatelessWidget {
  final String disputeId;

  const _DisputeDetailView({required this.disputeId});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Dispute Detail',
      body: BlocConsumer<DisputeBloc, DisputeState>(
        listener: (context, state) {
          if (state is DisputeOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            context.read<DisputeBloc>().add(LoadDisputeById(disputeId));
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
          if (state is DisputesLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is DisputeError) {
            return Center(
              child: AdminEmptyState(
                icon: Icons.error_outline,
                message: 'Error',
                message: state.message,
                description: 'Failed to load dispute',
                onAction: () => context
                    .read<DisputeBloc>()
                    .add(LoadDisputeById(disputeId)),
              ),
            );
          }
          if (state is DisputeDetailLoaded) {
            return _DisputeDetailContent(dispute: state.dispute);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _DisputeDetailContent extends StatelessWidget {
  final DisputeEntity dispute;

  const _DisputeDetailContent({required this.dispute});

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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminPageHeader(
            title: dispute.title,
            subtitle: dispute.ticketNumber,
            actions: _buildActions(context),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              AdminStatusBadge(
                label: dispute.status.displayName,
                color: _statusColor(dispute.status),
              ),
              const SizedBox(width: 8),
              DisputePriorityBadge(priority: dispute.priority),
              const SizedBox(width: 8),
              Chip(
                label: Text(dispute.type.displayName),
                backgroundColor: Colors.grey.shade200,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    _DisputeInfoCard(dispute: dispute),
                    const SizedBox(height: 16),
                    _TimelineCard(timeline: dispute.timeline),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _PartiesCard(dispute: dispute),
                    const SizedBox(height: 16),
                    if (dispute.resolution != null)
                      _ResolutionCard(resolution: dispute.resolution!),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    final actions = <Widget>[];
    if (dispute.status == DisputeStatus.open ||
        dispute.status == DisputeStatus.inProgress) {
      actions.addAll([
        ElevatedButton.icon(
          onPressed: () => _showResolveDialog(context),
          icon: const Icon(Icons.check_circle),
          label: const Text('Resolve'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: () => _showEscalateDialog(context),
          icon: const Icon(Icons.arrow_upward, color: Colors.red),
          label: const Text('Escalate', style: TextStyle(color: Colors.red)),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: () => _showUpdateStatusDialog(context),
          icon: const Icon(Icons.edit),
          label: const Text('Update Status'),
        ),
      ]);
    }
    return actions;
  }

  void _showResolveDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        child: SizedBox(
          width: 500,
          child: ResolutionForm(
            disputeId: dispute.id,
            onSubmit: (resolution) {
              context.read<DisputeBloc>().add(
                    ResolveDisputeEvent(dispute.id, resolution),
                  );
              Navigator.of(dialogContext).pop();
            },
          ),
        ),
      ),
    );
  }

  void _showEscalateDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Escalate Dispute'),
        content: SizedBox(
          width: 400,
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Reason for escalation *',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context.read<DisputeBloc>().add(
                      EscalateDisputeEvent(dispute.id, controller.text.trim()),
                    );
                Navigator.of(dialogContext).pop();
              }
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Escalate'),
          ),
        ],
      ),
    );
  }

  void _showUpdateStatusDialog(BuildContext context) {
    DisputeStatus? selected = dispute.status;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Update Status'),
          content: DropdownButton<DisputeStatus>(
            value: selected,
            isExpanded: true,
            items: DisputeStatus.values
                .map((s) =>
                    DropdownMenuItem(value: s, child: Text(s.displayName)))
                .toList(),
            onChanged: (v) => setDialogState(() => selected = v),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (selected != null) {
                  context.read<DisputeBloc>().add(
                        UpdateDisputeStatusEvent(dispute.id, selected!),
                      );
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DisputeInfoCard extends StatelessWidget {
  final DisputeEntity dispute;

  const _DisputeInfoCard({required this.dispute});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dispute Details',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            Text(dispute.description),
            const SizedBox(height: 16),
            if (dispute.orderId != null)
              _Row('Order ID', dispute.orderId!),
            if (dispute.amount != null)
              _Row('Amount', '₹${dispute.amount!.toStringAsFixed(2)}'),
            _Row('Created', _formatDate(dispute.createdAt)),
            _Row('Last Updated', _formatDate(dispute.updatedAt)),
            if (dispute.resolvedAt != null)
              _Row('Resolved At', _formatDate(dispute.resolvedAt!)),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day}/${d.month}/${d.year} ${d.hour}:${d.minute.toString().padLeft(2, '0')}';
}

class _Row extends StatelessWidget {
  final String label;
  final String value;

  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _PartiesCard extends StatelessWidget {
  final DisputeEntity dispute;

  const _PartiesCard({required this.dispute});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Parties',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            ListTile(
              leading:
                  const CircleAvatar(child: Icon(Icons.person)),
              title: Text(dispute.customerName),
              subtitle: Text(dispute.customerPhone),
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(height: 12),
            ListTile(
              leading:
                  const CircleAvatar(child: Icon(Icons.store)),
              title: Text(dispute.shopName),
              subtitle: Text('Shop ID: ${dispute.shopId}'),
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}

class _ResolutionCard extends StatelessWidget {
  final String resolution;

  const _ResolutionCard({required this.resolution});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Resolution',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(resolution),
          ],
        ),
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final List<DisputeTimelineEvent> timeline;

  const _TimelineCard({required this.timeline});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activity Timeline',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            if (timeline.isEmpty)
              const Text('No activity yet',
                  style: TextStyle(color: Colors.grey))
            else
              TimelineWidget(
                items: timeline
                    .map((t) => TimelineItem(
                          title: t.action,
                          description: '${t.description} — ${t.performedBy}',
                          timestamp: t.performedAt,
                        ))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}
