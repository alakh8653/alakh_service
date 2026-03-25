/// Custom chip/tag widget with filter, choice, and action variants.
library;

import 'package:flutter/material.dart';

/// Visual variant of [AppChip].
enum AppChipVariant {
  /// Toggleable filter chip (shows a check when selected).
  filter,

  /// Single-selection choice chip.
  choice,

  /// Actionable chip with a tap callback (no selection state).
  action,
}

/// A themed chip that supports filter, choice, and action use-cases.
///
/// ### Usage:
/// ```dart
/// AppChip(
///   label: 'Haircut',
///   variant: AppChipVariant.filter,
///   isSelected: _selected,
///   onTap: () => setState(() => _selected = !_selected),
/// )
/// ```
class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    this.variant = AppChipVariant.action,
    this.isSelected = false,
    this.onTap,
    this.onDelete,
    this.leading,
    this.avatar,
    this.isDisabled = false,
    this.selectedColor,
    this.unselectedColor,
    this.labelStyle,
    this.padding,
    this.borderRadius,
  });

  final String label;
  final AppChipVariant variant;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final Widget? leading;
  final Widget? avatar;
  final bool isDisabled;
  final Color? selectedColor;
  final Color? unselectedColor;
  final TextStyle? labelStyle;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    switch (variant) {
      case AppChipVariant.filter:
        return FilterChip(
          label: Text(label, style: labelStyle),
          selected: isSelected,
          onSelected: isDisabled ? null : (_) => onTap?.call(),
          avatar: avatar,
          selectedColor: selectedColor ?? theme.colorScheme.primaryContainer,
          deleteIcon: onDelete != null ? const Icon(Icons.close, size: 16) : null,
          onDeleted: onDelete,
          padding: padding,
          shape: borderRadius != null
              ? RoundedRectangleBorder(borderRadius: borderRadius!)
              : null,
        );

      case AppChipVariant.choice:
        return ChoiceChip(
          label: Text(label, style: labelStyle),
          selected: isSelected,
          onSelected: isDisabled ? null : (_) => onTap?.call(),
          avatar: avatar,
          selectedColor: selectedColor ?? theme.colorScheme.primaryContainer,
          padding: padding,
          shape: borderRadius != null
              ? RoundedRectangleBorder(borderRadius: borderRadius!)
              : null,
        );

      case AppChipVariant.action:
        return ActionChip(
          label: Text(label, style: labelStyle),
          onPressed: isDisabled ? null : onTap,
          avatar: leading ?? avatar,
          backgroundColor: isSelected
              ? (selectedColor ?? theme.colorScheme.primaryContainer)
              : (unselectedColor ?? theme.colorScheme.surfaceContainerHighest),
          padding: padding,
          shape: borderRadius != null
              ? RoundedRectangleBorder(borderRadius: borderRadius!)
              : null,
        );
    }
  }
}
