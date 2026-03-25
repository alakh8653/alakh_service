import 'package:flutter/material.dart';
import '../../domain/entities/dispute.dart';

class ResolutionCard extends StatelessWidget {
  final DisputeResolution resolution;
  final VoidCallback? onAccept;

  const ResolutionCard({super.key, required this.resolution, this.onAccept});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.gavel, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Resolution',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold, color: Colors.green[800]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _InfoRow(label: 'Outcome', value: resolution.outcome),
            if (resolution.refundAmount != null)
              _InfoRow(
                label: 'Refund Amount',
                value: '\$${resolution.refundAmount!.toStringAsFixed(2)}',
              ),
            _InfoRow(label: 'Notes', value: resolution.notes),
            _InfoRow(label: 'Resolved By', value: resolution.resolvedBy),
            if (onAccept != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green),
                  child: const Text('Accept Resolution'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: Colors.grey)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
