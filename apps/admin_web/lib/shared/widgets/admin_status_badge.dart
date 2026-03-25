import 'package:flutter/material.dart';

enum StatusType {
  active,
  inactive,
  pending,
  approved,
  rejected,
  flagged,
  resolved,
  warning,
  error,
  success,
  info,
}

class AdminStatusBadge extends StatelessWidget {
  final StatusType status;
  final String? label;
  final bool small;

  const AdminStatusBadge({
    super.key,
    required this.status,
    this.label,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getConfig(status);
    final fontSize = small ? 10.0 : 12.0;
    final iconSize = small ? 10.0 : 12.0;
    final padding = small
        ? const EdgeInsets.symmetric(horizontal: 6, vertical: 2)
        : const EdgeInsets.symmetric(horizontal: 8, vertical: 4);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: config.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: config.border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: iconSize, color: config.color),
          const SizedBox(width: 4),
          Text(
            label ?? config.defaultLabel,
            style: TextStyle(
              color: config.color,
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _getConfig(StatusType status) {
    switch (status) {
      case StatusType.active:
        return const _StatusConfig(
          color: Color(0xFF3FB950),
          background: Color(0xFF3FB9501A),
          border: Color(0xFF3FB95033),
          icon: Icons.check_circle_outline,
          defaultLabel: 'Active',
        );
      case StatusType.inactive:
        return const _StatusConfig(
          color: Color(0xFF8B949E),
          background: Color(0xFF8B949E1A),
          border: Color(0xFF8B949E33),
          icon: Icons.remove_circle_outline,
          defaultLabel: 'Inactive',
        );
      case StatusType.pending:
        return const _StatusConfig(
          color: Color(0xFFD29922),
          background: Color(0xFFD299221A),
          border: Color(0xFFD2992233),
          icon: Icons.schedule,
          defaultLabel: 'Pending',
        );
      case StatusType.approved:
        return const _StatusConfig(
          color: Color(0xFF3FB950),
          background: Color(0xFF3FB9501A),
          border: Color(0xFF3FB95033),
          icon: Icons.verified_outlined,
          defaultLabel: 'Approved',
        );
      case StatusType.rejected:
        return const _StatusConfig(
          color: Color(0xFFF85149),
          background: Color(0xFFF851491A),
          border: Color(0xFFF8514933),
          icon: Icons.cancel_outlined,
          defaultLabel: 'Rejected',
        );
      case StatusType.flagged:
        return const _StatusConfig(
          color: Color(0xFFF85149),
          background: Color(0xFFF851491A),
          border: Color(0xFFF8514933),
          icon: Icons.flag_outlined,
          defaultLabel: 'Flagged',
        );
      case StatusType.resolved:
        return const _StatusConfig(
          color: Color(0xFF1F6FEB),
          background: Color(0xFF1F6FEB1A),
          border: Color(0xFF1F6FEB33),
          icon: Icons.task_alt,
          defaultLabel: 'Resolved',
        );
      case StatusType.warning:
        return const _StatusConfig(
          color: Color(0xFFD29922),
          background: Color(0xFFD299221A),
          border: Color(0xFFD2992233),
          icon: Icons.warning_amber_outlined,
          defaultLabel: 'Warning',
        );
      case StatusType.error:
        return const _StatusConfig(
          color: Color(0xFFF85149),
          background: Color(0xFFF851491A),
          border: Color(0xFFF8514933),
          icon: Icons.error_outline,
          defaultLabel: 'Error',
        );
      case StatusType.success:
        return const _StatusConfig(
          color: Color(0xFF3FB950),
          background: Color(0xFF3FB9501A),
          border: Color(0xFF3FB95033),
          icon: Icons.check_circle_outline,
          defaultLabel: 'Success',
        );
      case StatusType.info:
        return const _StatusConfig(
          color: Color(0xFF58A6FF),
          background: Color(0xFF58A6FF1A),
          border: Color(0xFF58A6FF33),
          icon: Icons.info_outline,
          defaultLabel: 'Info',
        );
    }
  }
}

class _StatusConfig {
  final Color color;
  final Color background;
  final Color border;
  final IconData icon;
  final String defaultLabel;

  const _StatusConfig({
    required this.color,
    required this.background,
    required this.border,
    required this.icon,
    required this.defaultLabel,
  });
}
