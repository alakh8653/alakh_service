/// [Widget] extension methods for layout and interaction shortcuts.
library;

import 'package:flutter/material.dart';

/// Ergonomic widget-tree builders via extension methods.
extension WidgetExtensions on Widget {
  // ---------------------------------------------------------------------------
  // Padding
  // ---------------------------------------------------------------------------

  /// Wraps the widget in [Padding] with [EdgeInsets.all(value)].
  Widget paddingAll(double value) =>
      Padding(padding: EdgeInsets.all(value), child: this);

  /// Wraps the widget in [Padding] with symmetric [horizontal] / [vertical].
  Widget paddingSymmetric({double horizontal = 0, double vertical = 0}) =>
      Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontal,
          vertical: vertical,
        ),
        child: this,
      );

  /// Wraps the widget with custom [EdgeInsets].
  Widget paddingOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) =>
      Padding(
        padding: EdgeInsets.only(
          left: left,
          top: top,
          right: right,
          bottom: bottom,
        ),
        child: this,
      );

  // ---------------------------------------------------------------------------
  // Alignment / Layout
  // ---------------------------------------------------------------------------

  /// Centres the widget inside an [Align].
  Widget get centered => Center(child: this);

  /// Aligns the widget to [alignment] inside an [Align].
  Widget align(Alignment alignment) =>
      Align(alignment: alignment, child: this);

  /// Wraps in [Expanded] with [flex].
  Widget expanded({int flex = 1}) => Expanded(flex: flex, child: this);

  /// Wraps in [Flexible] with [flex] and [fit].
  Widget flexible({int flex = 1, FlexFit fit = FlexFit.loose}) =>
      Flexible(flex: flex, fit: fit, child: this);

  /// Wraps in a [SizedBox] with given [width] and / or [height].
  Widget sized({double? width, double? height}) =>
      SizedBox(width: width, height: height, child: this);

  /// Constrains to a square of [size].
  Widget square(double size) =>
      SizedBox.square(dimension: size, child: this);

  // ---------------------------------------------------------------------------
  // Visibility
  // ---------------------------------------------------------------------------

  /// Shows or hides the widget based on [visible].
  ///
  /// When [maintain] is `true` (default), the widget retains its layout space
  /// when hidden. Set [maintain] to `false` to fully remove it from the tree.
  Widget visibility({required bool visible, bool maintain = true}) =>
      maintain
          ? Visibility(visible: visible, child: this)
          : visible ? this : const SizedBox.shrink();

  // ---------------------------------------------------------------------------
  // Gesture
  // ---------------------------------------------------------------------------

  /// Wraps in a [GestureDetector] with an [onTap] callback.
  Widget onTap(VoidCallback? onTap) =>
      GestureDetector(onTap: onTap, child: this);

  /// Wraps in an [InkWell] with the specified [onTap] callback.
  Widget inkWell({
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    BorderRadius? borderRadius,
  }) =>
      InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: borderRadius,
        child: this,
      );

  // ---------------------------------------------------------------------------
  // Decoration
  // ---------------------------------------------------------------------------

  /// Wraps in a [DecoratedBox] with the supplied [decoration].
  Widget decorated(BoxDecoration decoration) =>
      DecoratedBox(decoration: decoration, child: this);

  /// Clips to a rounded rectangle with [radius].
  Widget clipRounded(double radius) => ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: this,
      );

  // ---------------------------------------------------------------------------
  // Sliver
  // ---------------------------------------------------------------------------

  /// Wraps in [SliverToBoxAdapter] for use inside a [CustomScrollView].
  Widget get sliverBox => SliverToBoxAdapter(child: this);
}
