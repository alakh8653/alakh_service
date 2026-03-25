import 'package:flutter/material.dart';

/// Shadow definitions used throughout the UI kit.
abstract class UiKitShadows {
  /// No shadow.
  static const List<BoxShadow> none = [];

  /// Subtle shadow for slightly elevated surfaces.
  static const List<BoxShadow> shadowSm = [
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  /// Medium shadow for cards and dropdowns.
  static const List<BoxShadow> shadowMd = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  /// Large shadow for modals and overlays.
  static const List<BoxShadow> shadowLg = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 15,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  /// Extra-large shadow for floating elements.
  static const List<BoxShadow> shadowXl = [
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 25,
      offset: Offset(0, 10),
    ),
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
  ];
}
