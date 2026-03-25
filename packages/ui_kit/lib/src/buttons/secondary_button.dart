import 'package:flutter/material.dart';

import '../theme/ui_kit_colors.dart';
import 'primary_button.dart';

/// A secondary filled button using a grey surface colour.
///
/// Set [onPressed] to `null` to disable. Set [isLoading] to show a spinner.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.size = ButtonSize.md,
    this.isLoading = false,
    this.isFullWidth = false,
    this.leadingIcon,
    this.trailingIcon,
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

    Widget content;
    if (isLoading) {
      content = SizedBox(
        width: _fontSize + 4,
        height: _fontSize + 4,
        child: const CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(UiKitColors.grey700),
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

    final button = ElevatedButton(
      onPressed: effectiveOnPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: UiKitColors.grey100,
        foregroundColor: UiKitColors.grey700,
        disabledBackgroundColor: UiKitColors.grey100,
        disabledForegroundColor: UiKitColors.grey400,
        elevation: 0,
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
