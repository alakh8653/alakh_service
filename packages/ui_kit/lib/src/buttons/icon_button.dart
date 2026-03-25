import 'package:flutter/material.dart';

import '../theme/ui_kit_colors.dart';

/// A circular icon button with optional tooltip and loading state.
///
/// Named [UiKitIconButton] to avoid conflict with Flutter's [IconButton].
class UiKitIconButton extends StatelessWidget {
  const UiKitIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.color,
    this.size = 24.0,
    this.tooltip,
    this.isLoading = false,
    this.backgroundColor,
    this.borderColor,
    this.padding,
  });

  /// Called when the button is tapped. `null` disables the button.
  final VoidCallback? onPressed;

  /// The icon to display.
  final IconData icon;

  /// Icon colour. Defaults to [UiKitColors.primary].
  final Color? color;

  /// Icon size. Defaults to 24.
  final double? size;

  /// Tooltip text shown on long-press.
  final String? tooltip;

  /// When `true`, shows a [CircularProgressIndicator] and disables interaction.
  final bool isLoading;

  /// Optional circular background fill colour.
  final Color? backgroundColor;

  /// Optional circular border colour.
  final Color? borderColor;

  /// Custom padding around the icon.
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = isLoading ? null : onPressed;
    final effectiveColor = color ?? UiKitColors.primary;
    final effectiveSize = size ?? 24.0;

    Widget content;
    if (isLoading) {
      content = SizedBox(
        width: effectiveSize,
        height: effectiveSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
        ),
      );
    } else {
      content = Icon(
        icon,
        color: effectiveOnPressed == null ? UiKitColors.grey400 : effectiveColor,
        size: effectiveSize,
      );
    }

    final button = InkWell(
      onTap: effectiveOnPressed,
      borderRadius: BorderRadius.circular(effectiveSize),
      child: Container(
        padding: padding ?? const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: borderColor != null
              ? Border.all(color: borderColor!, width: 1.5)
              : null,
        ),
        child: content,
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}
