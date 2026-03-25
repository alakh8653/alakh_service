import 'package:flutter/material.dart';

import '../theme/ui_kit_colors.dart';

/// A pill-shaped chip with optional leading icon, delete button, and selected state.
class UiKitChip extends StatelessWidget {
  const UiKitChip({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.leadingIcon,
    this.onTap,
    this.onDelete,
    this.selected = false,
    this.selectedBackgroundColor,
    this.selectedTextColor,
    this.padding,
  });

  final String label;

  /// Chip background when not selected.
  final Color? backgroundColor;

  /// Chip text / icon colour when not selected.
  final Color? textColor;

  /// Icon shown before the label.
  final IconData? leadingIcon;

  /// Callback for tapping the chip body.
  final VoidCallback? onTap;

  /// Callback for the delete (×) button. When `null`, no delete icon is shown.
  final VoidCallback? onDelete;

  /// Whether this chip is in a selected/active state.
  final bool selected;

  /// Background colour override for selected state.
  final Color? selectedBackgroundColor;

  /// Text colour override for selected state.
  final Color? selectedTextColor;

  final EdgeInsets? padding;

  Color get _bgColor {
    if (selected) return selectedBackgroundColor ?? UiKitColors.primary;
    return backgroundColor ?? UiKitColors.grey100;
  }

  Color get _fgColor {
    if (selected) return selectedTextColor ?? UiKitColors.white;
    return textColor ?? UiKitColors.grey700;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: padding ??
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _bgColor,
          borderRadius: const BorderRadius.all(Radius.circular(999)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leadingIcon != null) ...[
              Icon(leadingIcon, size: 14, color: _fgColor),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _fgColor,
              ),
            ),
            if (onDelete != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onDelete,
                child: Icon(Icons.close, size: 14, color: _fgColor),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
