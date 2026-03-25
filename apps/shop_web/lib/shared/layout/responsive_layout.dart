/// Breakpoint-aware responsive layout switcher.
library;

import 'package:flutter/material.dart';

/// Renders the correct child widget based on the current screen width.
///
/// Breakpoints:
/// * **mobile**  — width < 768 px
/// * **tablet**  — 768 px ≤ width < 1200 px
/// * **desktop** — width ≥ 1200 px
///
/// When [tablet] is omitted, [desktop] is used for both tablet and desktop
/// breakpoints.
///
/// Static helper predicates ([isMobile], [isTablet], [isDesktop]) can be used
/// inside build methods to conditionally adjust spacing, font sizes, etc.
class ResponsiveLayout extends StatelessWidget {
  /// Creates a [ResponsiveLayout].
  const ResponsiveLayout({
    required this.mobile,
    required this.desktop,
    this.tablet,
    super.key,
  });

  /// Widget shown on screens narrower than 768 px.
  final Widget mobile;

  /// Widget shown on screens between 768 px and 1199 px (inclusive).
  /// Falls back to [desktop] when not provided.
  final Widget? tablet;

  /// Widget shown on screens 1200 px wide or wider.
  final Widget desktop;

  // ---------------------------------------------------------------------------
  // Breakpoint constants
  // ---------------------------------------------------------------------------

  /// Maximum width (exclusive) for the mobile breakpoint.
  static const double mobileBreakpoint = 768;

  /// Maximum width (exclusive) for the tablet breakpoint.
  static const double tabletBreakpoint = 1200;

  // ---------------------------------------------------------------------------
  // Static helpers
  // ---------------------------------------------------------------------------

  /// Returns `true` when the current screen width is in the mobile range.
  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobileBreakpoint;

  /// Returns `true` when the current screen width is in the tablet range.
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  /// Returns `true` when the current screen width is in the desktop range.
  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tabletBreakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width >= tabletBreakpoint) return desktop;
        if (width >= mobileBreakpoint) return tablet ?? desktop;
        return mobile;
      },
    );
  }
}
