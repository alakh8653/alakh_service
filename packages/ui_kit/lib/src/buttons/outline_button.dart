import 'package:flutter/material.dart';

import '../theme/ui_kit_colors.dart';
import 'primary_button.dart';

/// A bordered outline button with [UiKitColors.primary] border and text.
///
/// Set [onPressed] to `null` to disable. Set [isLoading] to show a spinner.
class UiKitOutlineButton extends StatelessWidget {
  const UiKitOutlineButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.size = ButtonSize.md,
    this.isLoading = false,
    this.isFullWidth = false,
    this.leadingIcon,
    this.trailingIcon,
    this.borderColor,
  });

  /// Called when the button is tapped. `null` disables the button.
  final VoidCallback? onPressed;

  /// The label widget (usually a [Text]).
  final Widget child;

  /// Controls button padding and font size.
  final ButtonSize size;

  /// When `true`, shows a [CircularProgressIndicator] and disables interaction.
  final bool isLoading;

  /// When `true`, the button expands to fill available horizontal space.
  final bool isFullWidth;

  /// Optional icon shown before the label.
  final IconData? leadingIcon;

  /// Optional icon shown after the label.
  final IconData? trailingIcon;

  /// Override the default [UiKitColors.primary] border colour.
  final Color? borderColor;

  EdgeInsets get _padding {
    switch (size) {
      case ButtonSize.sm:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case ButtonSize.md:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 14);
      case ButtonSize.lg:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 18);
    }
  }

  double get _fontSize {
    switch (size) {
      case ButtonSize.sm:
        return 13;
      case ButtonSize.md:
        return 14;
      case ButtonSize.lg:
        return 16;
    }
  }

  double get _iconSize {
    switch (size) {
      case ButtonSize.sm:
        return 14;
      case ButtonSize.md:
        return 16;
      case ButtonSize.lg:
        return 18;
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = isLoading ? null : onPressed;
    final color = borderColor ?? UiKitColors.primary;

    Widget content;
    if (isLoading) {
      content = SizedBox(
        width: _fontSize + 4,
        height: _fontSize + 4,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    } else {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leadingIcon != null) ...[
            Icon(leadingIcon, size: _iconSize),
            SizedBox(width: _iconSize / 2),
          ],
          child,
          if (trailingIcon != null) ...[
            SizedBox(width: _iconSize / 2),
            Icon(trailingIcon, size: _iconSize),
          ],
        ],
      );
    }

    final button = OutlinedButton(
      onPressed: effectiveOnPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        disabledForegroundColor: UiKitColors.grey400,
        side: BorderSide(
          color: effectiveOnPressed == null ? UiKitColors.grey300 : color,
          width: 1.5,
        ),
        padding: _padding,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        textStyle: TextStyle(
          fontSize: _fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
      child: content,
    );

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}
