import 'package:flutter/material.dart';

import '../theme/ui_kit_colors.dart';

/// A styled horizontal divider with an optional centred [label].
class UiKitDivider extends StatelessWidget {
  const UiKitDivider({
    super.key,
    this.label,
    this.color,
    this.thickness = 1.0,
    this.indent = 0.0,
    this.endIndent = 0.0,
    this.labelStyle,
    this.padding,
  });

  /// Optional text shown in the centre of the divider.
  final String? label;

  /// Divider line colour. Defaults to [UiKitColors.grey200].
  final Color? color;

  final double thickness;
  final double indent;
  final double endIndent;

  /// Style for the [label] text.
  final TextStyle? labelStyle;

  /// Vertical padding around the entire widget.
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final lineColor = color ?? UiKitColors.grey200;

    if (label == null) {
      return Padding(
        padding: padding ?? EdgeInsets.zero,
        child: Divider(
          color: lineColor,
          thickness: thickness,
          indent: indent,
          endIndent: endIndent,
        ),
      );
    }

    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          if (indent > 0) SizedBox(width: indent),
          Expanded(
            child: Divider(
              color: lineColor,
              thickness: thickness,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label!,
              style: labelStyle ??
                  const TextStyle(
                    fontSize: 12,
                    color: UiKitColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Expanded(
            child: Divider(
              color: lineColor,
              thickness: thickness,
            ),
          ),
          if (endIndent > 0) SizedBox(width: endIndent),
        ],
      ),
    );
  }
}
