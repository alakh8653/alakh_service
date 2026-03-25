import 'package:flutter/material.dart';

import '../../domain/entities/tracking_status.dart';

/// Horizontal row of ordered status steps that highlights the current one.
class TrackingStatusBar extends StatelessWidget {
  /// The current status of the tracking session.
  final TrackingStatus currentStatus;

  /// Creates a [TrackingStatusBar].
  const TrackingStatusBar({
    super.key,
    required this.currentStatus,
  });

  static const List<(TrackingStatus, String, IconData)> _steps = [
    (TrackingStatus.notStarted, 'Pending', Icons.hourglass_empty),
    (TrackingStatus.staffEnRoute, 'En Route', Icons.directions_car),
    (TrackingStatus.staffArrived, 'Arrived', Icons.place),
    (TrackingStatus.serviceInProgress, 'In Progress', Icons.build),
    (TrackingStatus.completed, 'Done', Icons.check_circle),
  ];

  int get _currentIndex =>
      _steps.indexWhere((s) => s.$1 == currentStatus);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.surfaceVariant.withOpacity(0.5),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Row(
        children: List.generate(_steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            final stepIndex = i ~/ 2;
            final done = stepIndex < _currentIndex;
            return Expanded(
              child: Container(
                height: 2,
                color: done ? colorScheme.primary : Colors.grey[300],
              ),
            );
          }
          final stepIndex = i ~/ 2;
          final (status, label, icon) = _steps[stepIndex];
          final isCurrent = status == currentStatus;
          final isDone = stepIndex < _currentIndex;
          return _StatusStep(
            label: label,
            icon: icon,
            isCurrent: isCurrent,
            isDone: isDone,
          );
        }),
      ),
    );
  }
}

class _StatusStep extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isCurrent;
  final bool isDone;

  const _StatusStep({
    required this.label,
    required this.icon,
    required this.isCurrent,
    required this.isDone,
  });

  @override
  Widget build(BuildContext context) {
    final color = isCurrent
        ? Theme.of(context).colorScheme.primary
        : isDone
            ? Colors.green
            : Colors.grey[400]!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: color,
            fontWeight:
                isCurrent ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
