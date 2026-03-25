import 'package:flutter/material.dart';

/// Breakpoints that map device width to a [ScreenSize].
enum ScreenSize {
  /// Width < 600 px (phones).
  mobile,

  /// 600 px ≤ width < 1024 px (tablets, large phones in landscape).
  tablet,

  /// Width ≥ 1024 px (desktops, large tablets).
  desktop,
}

/// A widget that exposes the current [ScreenSize] through a builder function
/// and provides static helpers for common responsive checks.
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  /// Called with the current [BuildContext], resolved [ScreenSize], and the
  /// [BoxConstraints] from the parent [LayoutBuilder].
  final Widget Function(
    BuildContext context,
    ScreenSize screenSize,
    BoxConstraints constraints,
  ) builder;

  // ---------------------------------------------------------------------------
  // Static helpers
  // ---------------------------------------------------------------------------

  /// Resolves the [ScreenSize] for the current [BuildContext].
  static ScreenSize screenSizeOf(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return _fromWidth(width);
  }

  /// Returns `true` when the screen is [ScreenSize.mobile].
  static bool isMobile(BuildContext context) =>
      screenSizeOf(context) == ScreenSize.mobile;

  /// Returns `true` when the screen is [ScreenSize.tablet].
  static bool isTablet(BuildContext context) =>
      screenSizeOf(context) == ScreenSize.tablet;

  /// Returns `true` when the screen is [ScreenSize.desktop].
  static bool isDesktop(BuildContext context) =>
      screenSizeOf(context) == ScreenSize.desktop;

  static ScreenSize _fromWidth(double width) {
    if (width >= 1024) return ScreenSize.desktop;
    if (width >= 600) return ScreenSize.tablet;
    return ScreenSize.mobile;
  }

  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = _fromWidth(constraints.maxWidth);
        return builder(context, size, constraints);
      },
    );
  }
}
