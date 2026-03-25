import 'package:flutter/material.dart';
import '../../domain/entities/dispatch_status.dart';

/// Ordered list of statuses shown in the stepper (terminal states excluded).
const _kSteps = [
  DispatchStatus.assigned,
  DispatchStatus.accepted,
  DispatchStatus.enRoute,
  DispatchStatus.arrived,
  DispatchStatus.inProgress,
  DispatchStatus.completed,
];

/// A horizontal stepper that visually represents the dispatch job lifecycle.
class DispatchStatusStepper extends StatelessWidget {
  /// The current status of the job.
  final DispatchStatus currentStatus;

  const DispatchStatusStepper({
    super.key,
    required this.currentStatus,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentIndex = _kSteps.indexOf(currentStatus);

    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _kSteps.length,
        separatorBuilder: (_, index) => _StepConnector(
          isCompleted: index < currentIndex,
        ),
        itemBuilder: (context, index) {
          final step = _kSteps[index];
          final isCompleted = index < currentIndex;
          final isCurrent = index == currentIndex;

          return _StepDot(
            label: step.label,
            isCompleted: isCompleted,
            isCurrent: isCurrent,
            theme: theme,
          );
        },
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final String label;
  final bool isCompleted;
  final bool isCurrent;
  final ThemeData theme;

  const _StepDot({
    required this.label,
    required this.isCompleted,
    required this.isCurrent,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    Color dotColor;
    Color textColor;

    if (isCompleted) {
      dotColor = theme.colorScheme.primary;
      textColor = theme.colorScheme.primary;
    } else if (isCurrent) {
      dotColor = theme.colorScheme.primaryContainer;
      textColor = theme.colorScheme.onPrimaryContainer;
    } else {
      dotColor = theme.colorScheme.surfaceVariant;
      textColor = theme.colorScheme.outline;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isCurrent ? 28 : 20,
          height: isCurrent ? 28 : 20,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
            border: isCurrent
                ? Border.all(color: theme.colorScheme.primary, width: 2)
                : null,
          ),
          child: isCompleted
              ? Icon(Icons.check, size: 12, color: theme.colorScheme.onPrimary)
              : null,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(color: textColor),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _StepConnector extends StatelessWidget {
  final bool isCompleted;

  const _StepConnector({required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Container(
          width: 24,
          height: 2,
          color: isCompleted
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceVariant,
        ),
      ),
    );
  }
}
