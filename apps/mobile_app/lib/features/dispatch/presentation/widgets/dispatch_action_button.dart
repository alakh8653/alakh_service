import 'package:flutter/material.dart';
import '../../domain/entities/dispatch_status.dart';

/// Full-width action button whose label and callback change based on [status].
///
/// Provides the primary CTA for each dispatch lifecycle stage.
class DispatchActionButton extends StatelessWidget {
  final DispatchStatus status;
  final String jobId;
  final void Function(DispatchStatus nextStatus) onAction;

  const DispatchActionButton({
    super.key,
    required this.status,
    required this.jobId,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final config = _buttonConfig(status);
    if (config == null) return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () => onAction(config.nextStatus),
        icon: Icon(config.icon),
        label: Text(config.label),
        style: config.isDestructive
            ? FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              )
            : null,
      ),
    );
  }

  _ButtonConfig? _buttonConfig(DispatchStatus status) {
    switch (status) {
      case DispatchStatus.accepted:
        return const _ButtonConfig(
          label: 'Start Navigation',
          icon: Icons.navigation_outlined,
          nextStatus: DispatchStatus.enRoute,
        );
      case DispatchStatus.enRoute:
        return const _ButtonConfig(
          label: 'I Have Arrived',
          icon: Icons.location_on_outlined,
          nextStatus: DispatchStatus.arrived,
        );
      case DispatchStatus.arrived:
        return const _ButtonConfig(
          label: 'Start Service',
          icon: Icons.play_arrow_outlined,
          nextStatus: DispatchStatus.inProgress,
        );
      case DispatchStatus.inProgress:
        return const _ButtonConfig(
          label: 'Complete Job',
          icon: Icons.check_circle_outline,
          nextStatus: DispatchStatus.completed,
        );
      case DispatchStatus.pending:
      case DispatchStatus.assigned:
      case DispatchStatus.completed:
      case DispatchStatus.cancelled:
        return null;
    }
  }
}

class _ButtonConfig {
  final String label;
  final IconData icon;
  final DispatchStatus nextStatus;
  final bool isDestructive;

  const _ButtonConfig({
    required this.label,
    required this.icon,
    required this.nextStatus,
    this.isDestructive = false,
  });
}
