/// Reusable button widget with variants, loading state and disabled support.
library;

import 'package:flutter/material.dart';

/// The visual style variant of [AppButton].
enum AppButtonVariant {
  /// Filled button using the primary colour.
  primary,

  /// Filled button using a secondary / outline colour.
  secondary,

  /// Outlined (border-only) button.
  outlined,

  /// Transparent text-only button.
  text,

  /// Circular icon button.
  icon,
}

/// A reusable button widget with variants, sizes, loading and disabled states.
///
/// ### Usage:
/// ```dart
/// AppButton(
///   label: 'Book Now',
///   onPressed: _book,
///   variant: AppButtonVariant.primary,
///   isLoading: _isLoading,
/// )
/// ```
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.isDisabled = false,
    this.leadingIcon,
    this.trailingIcon,
    this.width,
    this.height = 52.0,
    this.borderRadius,
    this.padding,
    this.textStyle,
  }) : assert(
          variant != AppButtonVariant.icon,
          'Use AppButton.icon() constructor for icon variant.',
        );

  /// Convenience constructor for the icon button variant.
  const AppButton.icon({
    super.key,
    required this.leadingIcon,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.height = 48.0,
    this.width = 48.0,
    this.borderRadius,
    this.padding,
  })  : variant = AppButtonVariant.icon,
        label = '',
        trailingIcon = null,
        textStyle = null;

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool isDisabled;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final double? width;
  final double height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effective = isDisabled || isLoading ? null : onPressed;
    final radius = borderRadius ?? BorderRadius.circular(12);

    if (variant == AppButtonVariant.icon) {
      return SizedBox(
        width: width,
        height: height,
        child: IconButton.filled(
          onPressed: effective,
          icon: isLoading
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : (leadingIcon ?? const Icon(Icons.touch_app)),
        ),
      );
    }

    final content = isLoading
        ? SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: variant == AppButtonVariant.outlined ||
                      variant == AppButtonVariant.text
                  ? theme.colorScheme.primary
                  : Colors.white,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leadingIcon != null) ...[
                leadingIcon!,
                const SizedBox(width: 8),
              ],
              Text(label, style: textStyle),
              if (trailingIcon != null) ...[
                const SizedBox(width: 8),
                trailingIcon!,
              ],
            ],
          );

    final buttonStyle = _buildStyle(theme, radius);

    return SizedBox(
      width: width,
      height: height,
      child: switch (variant) {
        AppButtonVariant.outlined => OutlinedButton(
            style: buttonStyle,
            onPressed: effective,
            child: content,
          ),
        AppButtonVariant.text => TextButton(
            style: buttonStyle,
            onPressed: effective,
            child: content,
          ),
        _ => ElevatedButton(
            style: buttonStyle,
            onPressed: effective,
            child: content,
          ),
      },
    );
  }

  ButtonStyle _buildStyle(ThemeData theme, BorderRadius radius) {
    final padding =
        this.padding ?? const EdgeInsets.symmetric(horizontal: 24);
    switch (variant) {
      case AppButtonVariant.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          padding: padding,
          shape: RoundedRectangleBorder(borderRadius: radius),
          disabledBackgroundColor:
              theme.colorScheme.primary.withValues(alpha: 0.4),
        );
      case AppButtonVariant.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.secondary,
          foregroundColor: theme.colorScheme.onSecondary,
          padding: padding,
          shape: RoundedRectangleBorder(borderRadius: radius),
        );
      case AppButtonVariant.outlined:
        return OutlinedButton.styleFrom(
          foregroundColor: theme.colorScheme.primary,
          side: BorderSide(color: theme.colorScheme.primary),
          padding: padding,
          shape: RoundedRectangleBorder(borderRadius: radius),
        );
      case AppButtonVariant.text:
        return TextButton.styleFrom(
          foregroundColor: theme.colorScheme.primary,
          padding: padding,
          shape: RoundedRectangleBorder(borderRadius: radius),
        );
      default:
        return ElevatedButton.styleFrom(padding: padding);
    }
  }
}
