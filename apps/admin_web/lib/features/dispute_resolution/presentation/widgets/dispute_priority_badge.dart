import 'package:flutter/material.dart';
import 'package:admin_web/features/dispute_resolution/domain/entities/dispute_entity.dart';

class DisputePriorityBadge extends StatelessWidget {
  final DisputePriority priority;
  final bool showIcon;

  const DisputePriorityBadge({
    super.key,
    required this.priority,
    this.showIcon = true,
  });

  Color get _color {
    switch (priority) {
      case DisputePriority.low:
        return Colors.green;
      case DisputePriority.medium:
        return Colors.orange;
      case DisputePriority.high:
        return Colors.deepOrange;
      case DisputePriority.critical:
        return Colors.red;
    }
  }

  IconData get _icon {
    switch (priority) {
      case DisputePriority.low:
        return Icons.arrow_downward;
      case DisputePriority.medium:
        return Icons.remove;
      case DisputePriority.high:
        return Icons.arrow_upward;
      case DisputePriority.critical:
        return Icons.priority_high;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(_icon, size: 12, color: _color),
            const SizedBox(width: 4),
          ],
          Text(
            priority.displayName,
            style: TextStyle(
              fontSize: 12,
              color: _color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
