/// Custom dialog / modal builder with alert, confirm and custom variants.
library;

import 'package:flutter/material.dart';

/// Displays an alert dialog with a single "OK" button.
///
/// Returns when the user dismisses the dialog.
Future<void> showAppAlertDialog({
  required BuildContext context,
  required String title,
  required String message,
  String buttonLabel = 'OK',
}) =>
    showDialog<void>(
      context: context,
      builder: (_) => AppDialog.alert(
        title: title,
        message: message,
        buttonLabel: buttonLabel,
      ),
    );

/// Displays a confirm dialog with "Cancel" and "Confirm" actions.
///
/// Returns `true` when the user confirms, `false` otherwise.
Future<bool?> showAppConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool isDestructive = false,
}) =>
    showDialog<bool>(
      context: context,
      builder: (_) => AppDialog.confirm(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
      ),
    );

/// A flexible, reusable dialog widget.
///
/// Use the named constructors [AppDialog.alert], [AppDialog.confirm], or
/// the default constructor for fully custom content.
class AppDialog extends StatelessWidget {
  /// Creates a dialog with custom [content] and [actions].
  const AppDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions = const [],
    this.icon,
    this.showCloseButton = false,
  });

  /// Creates a simple alert dialog.
  factory AppDialog.alert({
    Key? key,
    required String title,
    required String message,
    String buttonLabel = 'OK',
  }) =>
      AppDialog(
        key: key,
        title: title,
        content: Text(message),
        actions: [
          _DialogAction(
            label: buttonLabel,
            onPressed: (ctx) => Navigator.of(ctx).pop(),
          ),
        ],
      );

  /// Creates a confirmation dialog.
  factory AppDialog.confirm({
    Key? key,
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
  }) =>
      AppDialog(
        key: key,
        title: title,
        content: Text(message),
        actions: [
          _DialogAction(
            label: cancelLabel,
            onPressed: (ctx) => Navigator.of(ctx).pop(false),
            isDefault: false,
          ),
          _DialogAction(
            label: confirmLabel,
            onPressed: (ctx) => Navigator.of(ctx).pop(true),
            isDestructive: isDestructive,
          ),
        ],
      );

  final String title;
  final Widget content;
  final List<_DialogAction> actions;
  final Widget? icon;
  final bool showCloseButton;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      icon: icon,
      title: Row(
        children: [
          Expanded(
            child: Text(title, style: theme.textTheme.titleLarge),
          ),
          if (showCloseButton)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
        ],
      ),
      content: content,
      actions: actions.map((a) => a.build(context)).toList(),
      actionsAlignment: MainAxisAlignment.end,
    );
  }
}

/// Internal action descriptor used by [AppDialog].
class _DialogAction {
  const _DialogAction({
    required this.label,
    required this.onPressed,
    this.isDefault = true,
    this.isDestructive = false,
  });

  final String label;
  final void Function(BuildContext context) onPressed;
  final bool isDefault;
  final bool isDestructive;

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (isDestructive) {
      return TextButton(
        onPressed: () => onPressed(context),
        style: TextButton.styleFrom(
          foregroundColor: theme.colorScheme.error,
        ),
        child: Text(label),
      );
    }
    if (!isDefault) {
      return TextButton(
        onPressed: () => onPressed(context),
        child: Text(label),
      );
    }
    return FilledButton(
      onPressed: () => onPressed(context),
      child: Text(label),
    );
  }
}
