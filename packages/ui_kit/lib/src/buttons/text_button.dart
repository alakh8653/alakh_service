import 'package:flutter/material.dart';

import '../theme/ui_kit_colors.dart';
import 'primary_button.dart';

/// A text-only button using [UiKitColors.primary] text colour.
///
/// Set [onPressed] to `null` to disable. Set [isLoading] to show a spinner.
class UiKitTextButton extends StatelessWidget {
  const UiKitTextButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.size = ButtonSize.md,
    this.isLoading = false,
    this.leadingIcon,
    this.trailingIcon,
    this.color,
  });

  /// Called when the button is tapped. `null` disables the button.
  final VoidCallback? onPressed;

  /// The label widget (usually a [Text]).
  final Widget child;

  /// Controls button padding and font size.
  final ButtonSize size;

  /// When `true`, shows a [CircularProgressIndicator] and disables interaction.
  final bool isLoading;

  /// Optional icon shown before the label.
  final IconData? leadingIcon;

  /// Optional icon shown after the label.
  final IconData? trailingIcon;

  /// Override the default foreground colour.
  final Color? color;

  EdgeInsets get _padding {
    switch (size) {
      case ButtonSize.sm:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
      case ButtonSize.md:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
      case ButtonSize.lg:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 14);
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
    final effectiveColor = color ?? UiKitColors.primary;

    Widget content;
    if (isLoading) {
      content = SizedBox(
        width: _fontSize + 4,
        height: _fontSize + 4,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
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

    return TextButton(
      onPressed: effectiveOnPressed,
      style: TextButton.styleFrom(
        foregroundColor: effectiveColor,
        disabledForegroundColor: UiKitColors.grey400,
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
  }
}
