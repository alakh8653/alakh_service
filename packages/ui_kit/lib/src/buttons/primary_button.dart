import 'package:flutter/material.dart';

import '../theme/ui_kit_colors.dart';

/// Controls the size of button variants.
enum ButtonSize { sm, md, lg }

/// A primary filled button using [UiKitColors.primary].
///
/// Set [onPressed] to `null` to disable the button.
/// Set [isLoading] to `true` to show a loading spinner.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
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

    final buttonChild = _ButtonContent(
      isLoading: isLoading,
      iconSize: _iconSize,
      fontSize: _fontSize,
      leadingIcon: leadingIcon,
      trailingIcon: trailingIcon,
      child: child,
    );

    final button = ElevatedButton(
      onPressed: effectiveOnPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: UiKitColors.primary,
        foregroundColor: UiKitColors.white,
        disabledBackgroundColor: UiKitColors.grey300,
        disabledForegroundColor: UiKitColors.grey500,
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
      child: buttonChild,
    );

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.isLoading,
    required this.iconSize,
    required this.fontSize,
    required this.child,
    this.leadingIcon,
    this.trailingIcon,
  });

  final bool isLoading;
  final double iconSize;
  final double fontSize;
  final Widget child;
  final IconData? leadingIcon;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        width: fontSize + 4,
        height: fontSize + 4,
        child: const CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(UiKitColors.white),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leadingIcon != null) ...[
          Icon(leadingIcon, size: iconSize),
          SizedBox(width: iconSize / 2),
        ],
        child,
        if (trailingIcon != null) ...[
          SizedBox(width: iconSize / 2),
          Icon(trailingIcon, size: iconSize),
        ],
      ],
    );
  }
}
