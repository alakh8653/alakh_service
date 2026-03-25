import 'package:flutter/material.dart';
import 'package:shop_web/features/queue_control/domain/entities/queue_item.dart';
import 'package:shop_web/shared/shared.dart';

/// A card representing a single entry in the service queue.
///
/// Highlights differently when the customer is currently being served.
class QueueItemCard extends StatelessWidget {
  const QueueItemCard({
    super.key,
    required this.item,
    required this.onCallNext,
    required this.onRemove,
    required this.isCurrentlyServing,
  });

  final QueueItem item;
  final VoidCallback onCallNext;
  final VoidCallback onRemove;
  final bool isCurrentlyServing;

  Color _statusColor(BuildContext context) {
    if (isCurrentlyServing) return Theme.of(context).colorScheme.primary;
    switch (item.status) {
      case 'waiting':
        return Colors.blue.shade700;
      case 'completed':
        return Colors.green.shade700;
      case 'cancelled':
      case 'noShow':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade600;
    }
  }

  StatusType _statusType() {
    switch (item.status) {
      case 'serving':
        return StatusType.info;
      case 'completed':
        return StatusType.success;
      case 'cancelled':
      case 'noShow':
        return StatusType.error;
      default:
        return StatusType.pending;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = isCurrentlyServing
        ? theme.colorScheme.primary
        : Colors.transparent;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: isCurrentlyServing
            ? theme.colorScheme.primary.withOpacity(0.06)
            : theme.cardColor,
        border: Border.all(color: borderColor, width: 2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Position badge
            _PositionBadge(
              position: item.position,
              color: _statusColor(context),
            ),
            const SizedBox(width: 14),

            // Customer & service info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.customerName,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      StatusBadge(
                        label: _statusLabel(),
                        type: _statusType(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.serviceName,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.phone_outlined,
                          size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        item.customerPhone,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.access_time_outlined,
                          size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        '~${item.estimatedWaitMinutes} min',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: Colors.grey[600]),
                      ),
                      if (item.assignedStaffName != null) ...[
                        const SizedBox(width: 12),
                        Icon(Icons.person_outline,
                            size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          item.assignedStaffName!,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                  if (item.notes != null && item.notes!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.notes!,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.orange[700]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Actions
            if (item.isWaiting || item.isServing)
              ActionMenu(
                items: [
                  if (item.isWaiting)
                    ActionMenuItem(
                      label: 'Call Next',
                      icon: Icons.call_rounded,
                      onTap: onCallNext,
                    ),
                  ActionMenuItem(
                    label: 'Mark No Show',
                    icon: Icons.person_off_outlined,
                    onTap: () {},
                  ),
                  ActionMenuItem(
                    label: 'Remove',
                    icon: Icons.remove_circle_outline,
                    onTap: onRemove,
                    isDestructive: true,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _statusLabel() {
    switch (item.status) {
      case 'serving':
        return 'Serving';
      case 'waiting':
        return 'Waiting';
      case 'completed':
        return 'Done';
      case 'cancelled':
        return 'Cancelled';
      case 'noShow':
        return 'No Show';
      default:
        return item.status;
    }
  }
}

class _PositionBadge extends StatelessWidget {
  const _PositionBadge({required this.position, required this.color});
  final int position;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        '#$position',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}
