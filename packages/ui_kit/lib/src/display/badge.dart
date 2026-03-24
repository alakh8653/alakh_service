import 'package:flutter/material.dart';

import '../theme/ui_kit_colors.dart';

/// Overlays a count badge on any [child] widget.
///
/// Position the badge using [alignment] (defaults to top-right corner).
class Badge extends StatelessWidget {
  const Badge({
    super.key,
    required this.child,
    this.count,
    this.showWhenZero = false,
    this.backgroundColor,
    this.textColor,
    this.size = 18.0,
    this.alignment = Alignment.topRight,
    this.offset,
  });

  /// The widget the badge is placed on top of.
  final Widget child;

  /// Count to display. When `null`, shows a dot without a number.
  final int? count;

  /// When `false` (default) the badge is hidden when [count] is 0.
  final bool showWhenZero;

  /// Badge fill colour. Defaults to [UiKitColors.error].
  final Color? backgroundColor;

  /// Badge text colour. Defaults to [UiKitColors.white].
  final Color? textColor;

  /// Diameter of the badge circle.
  final double size;

  /// Corner of the child where the badge appears.
  final AlignmentGeometry alignment;

  /// Optional pixel offset applied to the badge.
  final Offset? offset;

  bool get _visible {
    if (count == null) return true;
    return showWhenZero || count! > 0;
  }

  String get _label {
    if (count == null) return '';
    return count! > 99 ? '99+' : '$count';
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return child;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned.fill(
          child: Align(
            alignment: alignment,
            child: Transform.translate(
              offset: offset ?? Offset(size * 0.3, -(size * 0.3)),
              child: Container(
                constraints: BoxConstraints(
                  minWidth: size,
                  minHeight: size,
                ),
                padding: count != null && count! > 9
                    ? const EdgeInsets.symmetric(horizontal: 4)
                    : EdgeInsets.zero,
                decoration: BoxDecoration(
                  color: backgroundColor ?? UiKitColors.error,
                  borderRadius: BorderRadius.circular(size / 2),
                ),
                child: Center(
                  child: Text(
                    _label,
                    style: TextStyle(
                      color: textColor ?? UiKitColors.white,
                      fontSize: size * 0.6,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
