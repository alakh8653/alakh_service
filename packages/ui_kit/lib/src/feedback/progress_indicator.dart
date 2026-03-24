import 'package:flutter/material.dart';

import '../theme/ui_kit_colors.dart';

/// A unified progress indicator that can render either circular or linear style.
///
/// When [value] is `null` the indicator is indeterminate (animated).
class UiKitProgressIndicator extends StatelessWidget {
  const UiKitProgressIndicator({
    super.key,
    this.circular = true,
    this.value,
    this.color,
    this.strokeWidth,
    this.backgroundColor,
    this.minHeight,
  });

  /// When `true`, renders a [CircularProgressIndicator]; otherwise renders
  /// a [LinearProgressIndicator].
  final bool circular;

  /// Progress value between 0.0 and 1.0. `null` for indeterminate.
  final double? value;

  /// Indicator colour. Defaults to [UiKitColors.primary].
  final Color? color;

  /// Stroke width for circular variant. Defaults to 3.
  final double? strokeWidth;

  /// Track colour behind the indicator.
  final Color? backgroundColor;

  /// Minimum height for the linear variant.
  final double? minHeight;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? UiKitColors.primary;
    final trackColor = backgroundColor ?? UiKitColors.grey200;

    if (circular) {
      return CircularProgressIndicator(
        value: value,
        color: effectiveColor,
        backgroundColor: trackColor,
        strokeWidth: strokeWidth ?? 3.0,
      );
    }

    return LinearProgressIndicator(
      value: value,
      color: effectiveColor,
      backgroundColor: trackColor,
      minHeight: minHeight ?? 4.0,
      borderRadius: const BorderRadius.all(Radius.circular(4)),
    );
  }
}
