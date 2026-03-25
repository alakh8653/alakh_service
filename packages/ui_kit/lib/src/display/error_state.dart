import 'package:flutter/material.dart';

import '../theme/ui_kit_colors.dart';

/// A centred error state with icon, title, message, and an optional retry action.
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.message,
    this.title,
    this.onRetry,
    this.icon,
    this.padding,
    this.retryLabel,
  });

  /// The primary error description shown below the title.
  final String message;

  /// Optional bold heading above [message].
  final String? title;

  /// Callback invoked when the user taps the retry button.
  final VoidCallback? onRetry;

  /// Custom icon widget. Defaults to a red error_outline icon.
  final Widget? icon;

  final EdgeInsets? padding;

  /// Label for the retry button. Defaults to "Try again".
  final String? retryLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding ?? const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon ??
                const Icon(
                  Icons.error_outline_rounded,
                  size: 64,
                  color: UiKitColors.error,
                ),
            const SizedBox(height: 16),
            if (title != null) ...[
              Text(
                title!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: UiKitColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
            ],
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: UiKitColors.textSecondary,
                height: 1.5,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: Text(retryLabel ?? 'Try again'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: UiKitColors.primary,
                  side: const BorderSide(color: UiKitColors.primary),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
