import 'package:flutter/material.dart';

import '../theme/ui_kit_colors.dart';

/// Utility class providing static methods to display styled [SnackBar]s.
abstract class UiKitSnackBar {
  /// Shows a green success snack bar.
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message: message,
      backgroundColor: UiKitColors.success,
      icon: Icons.check_circle_outline_rounded,
      duration: duration,
    );
  }

  /// Shows a red error snack bar.
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    _show(
      context,
      message: message,
      backgroundColor: UiKitColors.error,
      icon: Icons.error_outline_rounded,
      duration: duration,
    );
  }

  /// Shows an amber warning snack bar.
  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message: message,
      backgroundColor: UiKitColors.warning,
      icon: Icons.warning_amber_rounded,
      duration: duration,
      textColor: UiKitColors.grey900,
    );
  }

  /// Shows a blue info snack bar.
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message: message,
      backgroundColor: UiKitColors.info,
      icon: Icons.info_outline_rounded,
      duration: duration,
    );
  }

  static void _show(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    required IconData icon,
    Duration duration = const Duration(seconds: 3),
    Color textColor = UiKitColors.white,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: duration,
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          content: Row(
            children: [
              Icon(icon, color: textColor, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
