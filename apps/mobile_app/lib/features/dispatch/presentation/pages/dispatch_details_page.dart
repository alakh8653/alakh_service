import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/dispatch_job.dart';
import '../../domain/entities/dispatch_location.dart';
import '../../domain/entities/dispatch_status.dart';
import '../bloc/dispatch_bloc.dart';
import '../bloc/dispatch_event.dart';
import '../bloc/dispatch_state.dart';
import '../widgets/dispatch_status_stepper.dart';
import '../widgets/dispatch_action_button.dart';

/// Full-detail scrollable view of a dispatch job.
class DispatchDetailsPage extends StatelessWidget {
  final DispatchJob job;

  const DispatchDetailsPage({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Job #${job.id.substring(0, 8)}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DispatchStatusStepper(currentStatus: job.status),
            const SizedBox(height: 20),
            const _SectionHeader(label: 'Job Details'),
            _DetailRow(label: 'Booking ID', value: job.bookingId),
            _DetailRow(label: 'Status', value: job.status.label),
            _DetailRow(
              label: 'Fare',
              value: '₹${job.fare.toStringAsFixed(2)}',
            ),
            _DetailRow(
              label: 'Distance',
              value: '${job.distance.toStringAsFixed(1)} km',
            ),
            _DetailRow(
              label: 'Est. Duration',
              value: _formatDuration(job.estimatedDuration),
            ),
            _DetailRow(
              label: 'Created',
              value: _formatDateTime(job.createdAt),
            ),
            if (job.notes != null && job.notes!.isNotEmpty) ...[
              _DetailRow(label: 'Notes', value: job.notes!),
            ],
            const SizedBox(height: 20),
            const _SectionHeader(label: 'Pickup Location'),
            _LocationCard(location: job.pickupLocation),
            const SizedBox(height: 12),
            const _SectionHeader(label: 'Dropoff Location'),
            _LocationCard(location: job.dropoffLocation),
            const SizedBox(height: 24),
            if (job.status.isActive)
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
      ),
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;

  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  final DispatchLocation location;

  const _LocationCard({required this.location});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            location.address,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(
            '${location.lat.toStringAsFixed(6)}, ${location.lng.toStringAsFixed(6)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }
}
