/// Custom snackbar / toast with success, error, warning, and info variants.
library;

import 'package:flutter/material.dart';

/// Visual style of an [AppSnackbar].
enum AppSnackbarStyle {
  success,
  error,
  warning,
  info,
}

/// Helper class for showing styled snackbars.
///
/// Call the static methods on [AppSnackbar] from any [BuildContext].
///
/// ### Usage:
/// ```dart
/// AppSnackbar.success(context, 'Booking confirmed!');
/// AppSnackbar.error(context, 'Something went wrong.');
/// ```
abstract final class AppSnackbar {
  static void success(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) =>
      _show(context, message, AppSnackbarStyle.success,
          duration: duration, action: action);

  static void error(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) =>
      _show(context, message, AppSnackbarStyle.error,
          duration: duration, action: action);

  static void warning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) =>
      _show(context, message, AppSnackbarStyle.warning,
          duration: duration, action: action);

  static void info(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) =>
      _show(context, message, AppSnackbarStyle.info,
          duration: duration, action: action);

  static void _show(
    BuildContext context,
    String message,
    AppSnackbarStyle style, {
    required Duration duration,
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(_buildSnackBar(context, message, style, duration, action));
  }

  static SnackBar _buildSnackBar(
    BuildContext context,
    String message,
    AppSnackbarStyle style,
    Duration duration,
    SnackBarAction? action,
  ) {
    final theme = Theme.of(context);
    final (bgColor, iconData) = _resolveStyle(style, theme);

    return SnackBar(
      duration: duration,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      backgroundColor: bgColor,
      content: Row(
        children: [
          Icon(iconData, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
      action: action,
    );
  }

  static (Color, IconData) _resolveStyle(
    AppSnackbarStyle style,
    ThemeData theme,
  ) {
    return switch (style) {
      AppSnackbarStyle.success => (const Color(0xFF2E7D32), Icons.check_circle_outline),
      AppSnackbarStyle.error => (theme.colorScheme.error, Icons.error_outline),
      AppSnackbarStyle.warning => (const Color(0xFFE65100), Icons.warning_amber_rounded),
      AppSnackbarStyle.info => (const Color(0xFF1565C0), Icons.info_outline),
    };
  }
}
