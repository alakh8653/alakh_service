import 'package:flutter/material.dart';
import '../../domain/entities/dispute.dart';
import '../../domain/entities/dispute_status.dart';
import '../../domain/entities/dispute_type.dart';

class DisputeCard extends StatelessWidget {
  final Dispute dispute;
  final VoidCallback? onTap;

  const DisputeCard({super.key, required this.dispute, this.onTap});

  Color _statusColor(DisputeStatus status) {
    switch (status) {
      case DisputeStatus.draft: return Colors.grey;
      case DisputeStatus.submitted: return Colors.blue;
      case DisputeStatus.underReview: return Colors.orange;
      case DisputeStatus.awaitingResponse: return Colors.amber;
      case DisputeStatus.escalated: return Colors.red;
      case DisputeStatus.resolved: return Colors.green;
      case DisputeStatus.closed: return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      dispute.type.displayName,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor(dispute.status).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      dispute.status.displayName,
                      style: TextStyle(
                        color: _statusColor(dispute.status),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                dispute.reason,
                style: theme.textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Booking: ${dispute.bookingId}',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(dispute.createdAt),
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
