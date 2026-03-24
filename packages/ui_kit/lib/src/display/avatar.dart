import 'package:flutter/material.dart';

import '../theme/ui_kit_colors.dart';

/// A circular avatar that shows a [NetworkImage] when [imageUrl] is provided,
/// or falls back to initials derived from [name].
///
/// An optional green online-indicator dot is shown when [isOnline] is `true`.
class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = 40.0,
    this.isOnline = false,
    this.backgroundColor,
    this.onTap,
    this.borderColor,
    this.borderWidth = 0,
  });

  /// Remote image URL. Takes precedence over [name] initials.
  final String? imageUrl;

  /// Full name used to generate initials when [imageUrl] is absent.
  final String? name;

  /// Diameter of the avatar circle.
  final double size;

  /// When `true`, shows a small green dot in the bottom-right corner.
  final bool isOnline;

  /// Background colour for the initials fallback.
  final Color? backgroundColor;

  /// Optional tap callback.
  final VoidCallback? onTap;

  /// Optional border colour around the circle.
  final Color? borderColor;

  /// Width of the optional border.
  final double borderWidth;

  /// Extracts up to 2 initials from [name].
  String get _initials {
    if (name == null || name!.trim().isEmpty) return '?';
    final parts = name!.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length.clamp(0, 2)).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Color get _bgColor {
    if (backgroundColor != null) return backgroundColor!;
    // Deterministic colour from name hash.
    if (name != null) {
      const palette = [
        Color(0xFF6C63FF),
        Color(0xFF00C896),
        Color(0xFF3B82F6),
        Color(0xFFF59E0B),
        Color(0xFFEF4444),
        Color(0xFF8B5CF6),
      ];
      return palette[name.hashCode.abs() % palette.length];
    }
    return UiKitColors.grey400;
  }

  double get _fontSize => (size * 0.38).clamp(10, 24);

  @override
  Widget build(BuildContext context) {
    Widget circle = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: imageUrl != null ? null : _bgColor,
        border: borderWidth > 0 && borderColor != null
            ? Border.all(color: borderColor!, width: borderWidth)
            : null,
        image: imageUrl != null
            ? DecorationImage(
                image: NetworkImage(imageUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: imageUrl == null
          ? Center(
              child: Text(
                _initials,
                style: TextStyle(
                  color: UiKitColors.white,
                  fontSize: _fontSize,
                  fontWeight: FontWeight.w600,
                  height: 1,
                ),
              ),
            )
          : null,
    );

    if (isOnline) {
      final dotSize = (size * 0.28).clamp(8.0, 14.0);
      circle = Stack(
        children: [
          circle,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: dotSize,
              height: dotSize,
              decoration: BoxDecoration(
                color: UiKitColors.success,
                shape: BoxShape.circle,
                border: Border.all(color: UiKitColors.white, width: 1.5),
              ),
            ),
          ),
        ],
      );
    }

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: circle);
    }
    return circle;
  }
}
