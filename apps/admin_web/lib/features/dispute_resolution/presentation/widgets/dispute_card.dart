import 'package:flutter/material.dart';
import 'package:admin_web/features/dispute_resolution/domain/entities/dispute_entity.dart';
import 'package:admin_web/shared/shared.dart';
import 'package:admin_web/features/dispute_resolution/presentation/widgets/dispute_priority_badge.dart';

class DisputeCard extends StatelessWidget {
  final DisputeEntity dispute;
  final VoidCallback? onTap;
  final VoidCallback? onResolve;
  final VoidCallback? onEscalate;

  const DisputeCard({
    super.key,
    required this.dispute,
    this.onTap,
    this.onResolve,
    this.onEscalate,
  });

  Color _statusColor(DisputeStatus status) {
    switch (status) {
      case DisputeStatus.open:
        return Colors.blue;
      case DisputeStatus.inProgress:
        return Colors.orange;
      case DisputeStatus.escalated:
        return Colors.red;
      case DisputeStatus.resolved:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    dispute.ticketNumber,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  DisputePriorityBadge(priority: dispute.priority),
                  const SizedBox(width: 8),
                  AdminStatusBadge(
                    label: dispute.status.displayName,
                    color: _statusColor(dispute.status),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                dispute.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.person, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    dispute.customerName,
                    style: TextStyle(
                        color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.store, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    dispute.shopName,
                    style: TextStyle(
                        color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.label, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    dispute.type.displayName,
                    style: TextStyle(
                        color: Colors.grey.shade600, fontSize: 12),
                  ),
                  if (dispute.amount != null) ...[
                    const SizedBox(width: 12),
                    const Icon(Icons.currency_rupee,
                        size: 14, color: Colors.grey),
                    Text(
                      dispute.amount!.toStringAsFixed(2),
                      style: TextStyle(
                          color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ],
              ),
              if (onResolve != null || onEscalate != null) ...[
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onEscalate != null)
                      TextButton.icon(
                        onPressed: onEscalate,
                        icon: const Icon(Icons.arrow_upward,
                            size: 16, color: Colors.red),
                        label: const Text('Escalate',
                            style: TextStyle(color: Colors.red)),
                      ),
                    if (onResolve != null)
                      ElevatedButton.icon(
                        onPressed: onResolve,
                        icon: const Icon(Icons.check_circle, size: 16),
                        label: const Text('Resolve'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
