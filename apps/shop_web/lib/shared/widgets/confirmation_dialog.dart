/// Reusable confirmation / destructive-action dialog.
library;

import 'package:flutter/material.dart';

/// A simple AlertDialog that asks the user to confirm or cancel an action.
///
/// Use the static [ConfirmationDialog.show] factory to display the dialog and
/// await a `bool?` result (`true` = confirmed, `false` = cancelled,
/// `null` = dismissed).
///
/// ```dart
/// final confirmed = await ConfirmationDialog.show(
///   context: context,
///   title: 'Delete booking',
///   message: 'This action cannot be undone.',
///   confirmLabel: 'Delete',
///   confirmColor: Colors.red,
///   onConfirm: () => bloc.add(DeleteBooking(id)),
/// );
/// ```
class ConfirmationDialog extends StatelessWidget {
  /// Creates a [ConfirmationDialog].
  const ConfirmationDialog({
    required this.title,
    required this.message,
    required this.onConfirm,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.confirmColor,
    super.key,
  });

  /// Dialog heading.
  final String title;

  /// Body copy explaining the action.
  final String message;

  /// Label for the confirm button.
  final String confirmLabel;

  /// Label for the cancel / dismiss button.
  final String cancelLabel;

  /// Background colour of the confirm button.  Defaults to
  /// `colorScheme.primary`.  Pass `Colors.red` for destructive actions.
  final Color? confirmColor;

  /// Called synchronously when the user taps the confirm button, before the
  /// dialog is closed.
  final VoidCallback onConfirm;

  // ---------------------------------------------------------------------------
  // Static helper
  // ---------------------------------------------------------------------------

  /// Shows the dialog and returns `true` if confirmed, `false` if cancelled,
  /// or `null` if dismissed by tapping outside.
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onConfirm,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    Color? confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => ConfirmationDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        confirmColor: confirmColor,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveConfirmColor = confirmColor ?? colorScheme.primary;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      content: Text(message, style: theme.textTheme.bodyMedium),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: effectiveConfirmColor,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop(true);
          },
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}
