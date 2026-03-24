/// Empty-state placeholder for data tables and lists.
library;

import 'package:flutter/material.dart';

/// Displays a centred illustration, message, and optional action button when
/// a data table or list has no items to show.
class EmptyTableState extends StatelessWidget {
  /// Creates an [EmptyTableState].
  const EmptyTableState({
    required this.message,
    required this.icon,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  /// Primary message explaining why the list is empty.
  final String message;

  /// Icon rendered above the message.
  final IconData icon;

  /// Optional label for the action button.  If `null` the button is hidden.
  final String? actionLabel;

  /// Called when the user taps the action button.  Ignored when
  /// [actionLabel] is `null`.
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtle = theme.colorScheme.onSurface.withOpacity(0.35);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: subtle),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(color: subtle),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
