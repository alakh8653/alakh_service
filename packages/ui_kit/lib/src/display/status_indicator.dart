import 'package:flutter/material.dart';

import '../theme/ui_kit_colors.dart';

/// Represents the status of an entity.
enum IndicatorStatus { online, offline, away, busy, unknown }

/// A small coloured circle used to communicate status at a glance.
class StatusIndicator extends StatelessWidget {
  const StatusIndicator({
    super.key,
    required this.status,
    this.size = 10.0,
    this.borderColor,
    this.borderWidth = 0,
    this.color,
    this.label,
    this.labelStyle,
  });

  final IndicatorStatus status;

  /// Diameter of the dot.
  final double size;

  /// Optional border around the dot.
  final Color? borderColor;
  final double borderWidth;

  /// Override the default status colour.
  final Color? color;

  /// Optional text label shown to the right of the dot.
  final String? label;
  final TextStyle? labelStyle;

  Color get _defaultColor {
    switch (status) {
      case IndicatorStatus.online:
        return UiKitColors.success;
      case IndicatorStatus.offline:
        return UiKitColors.grey400;
      case IndicatorStatus.away:
        return UiKitColors.warning;
      case IndicatorStatus.busy:
        return UiKitColors.error;
      case IndicatorStatus.unknown:
        return UiKitColors.grey300;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dot = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color ?? _defaultColor,
        shape: BoxShape.circle,
        border: borderWidth > 0 && borderColor != null
            ? Border.all(color: borderColor!, width: borderWidth)
            : null,
      ),
    );

    if (label == null) return dot;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        dot,
        const SizedBox(width: 6),
        Text(
          label!,
          style: labelStyle ??
              const TextStyle(
                fontSize: 12,
                color: UiKitColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
