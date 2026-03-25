import 'package:flutter/material.dart';
import '../../domain/entities/dispute_status.dart';

class DisputeStatusTimeline extends StatelessWidget {
  final DisputeStatus currentStatus;

  const DisputeStatusTimeline({super.key, required this.currentStatus});

  static const _stages = [
    DisputeStatus.submitted,
    DisputeStatus.underReview,
    DisputeStatus.awaitingResponse,
    DisputeStatus.resolved,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentIndex = _stages.indexOf(currentStatus);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: List.generate(_stages.length * 2 - 1, (i) {
          if (i.isOdd) {
            final stageIndex = i ~/ 2;
            final isCompleted = currentIndex > stageIndex;
            return Expanded(
              child: Container(
                height: 2,
                color: isCompleted
                    ? theme.colorScheme.primary
                    : Colors.grey[300],
              ),
            );
          }
          final stageIndex = i ~/ 2;
          final isCompleted = currentIndex >= stageIndex;
          final isCurrent = currentIndex == stageIndex;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? theme.colorScheme.primary
                      : Colors.grey[300],
                  border: isCurrent
                      ? Border.all(
                          color: theme.colorScheme.primary, width: 3)
                      : null,
                ),
                child: Icon(
                  isCompleted ? Icons.check : Icons.circle,
                  size: 16,
                  color: isCompleted ? Colors.white : Colors.grey[400],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _stages[stageIndex].displayName,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isCompleted
                      ? theme.colorScheme.primary
                      : Colors.grey[500],
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          );
        }),
      ),
    );
  }
}
