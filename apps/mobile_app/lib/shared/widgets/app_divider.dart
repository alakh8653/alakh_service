/// Custom divider widget with optional centred label.
library;

import 'package:flutter/material.dart';

/// A horizontal divider that can optionally display a centred [label].
///
/// ### Usage:
/// ```dart
/// const AppDivider()               // plain line
/// AppDivider(label: 'OR')          // line with text
/// ```
class AppDivider extends StatelessWidget {
  const AppDivider({
    super.key,
    this.label,
    this.thickness = 1,
    this.color,
    this.height,
    this.indent = 0,
    this.endIndent = 0,
    this.labelStyle,
    this.labelPadding = const EdgeInsets.symmetric(horizontal: 12),
  });

  /// Optional text shown in the centre of the divider.
  final String? label;

  /// Thickness of the dividing line.
  final double thickness;

  /// Colour of the line (defaults to the theme divider colour).
  final Color? color;

  /// Total height of the widget (whitespace + line).
  final double? height;

  /// Left indent.
  final double indent;

  /// Right indent.
  final double endIndent;

  /// Style for [label].
  final TextStyle? labelStyle;

  /// Horizontal padding around [label].
  final EdgeInsetsGeometry labelPadding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lineColor = color ?? theme.dividerColor;

    if (label == null) {
      return Divider(
        thickness: thickness,
        color: lineColor,
        height: height,
        indent: indent,
        endIndent: endIndent,
      );
    }

    final line = Expanded(
      child: Divider(
        thickness: thickness,
        color: lineColor,
        height: height ?? 16,
      ),
    );

    return Row(
      children: [
        if (indent > 0) SizedBox(width: indent),
        line,
        Padding(
          padding: labelPadding,
          child: Text(
            label!,
            style: labelStyle ??
                theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
          ),
        ),
        line,
        if (endIndent > 0) SizedBox(width: endIndent),
      ],
    );
  }
}
