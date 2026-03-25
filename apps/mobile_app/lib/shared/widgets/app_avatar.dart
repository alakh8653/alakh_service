/// User avatar widget with initials fallback, online indicator, and sizes.
library;

import 'package:flutter/material.dart';

import 'app_image.dart';

/// Size enum for [AppAvatar].
enum AppAvatarSize {
  xs(24),
  sm(36),
  md(48),
  lg(72),
  xl(96);

  const AppAvatarSize(this.value);
  final double value;
}

/// A circular avatar that displays a network image, or falls back to the
/// user's initials on a coloured background.
///
/// Optionally shows an online indicator badge.
///
/// ### Usage:
/// ```dart
/// AppAvatar(
///   imageUrl: user.photoUrl,
///   name: user.displayName,
///   size: AppAvatarSize.md,
///   isOnline: user.isOnline,
/// )
/// ```
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = AppAvatarSize.md,
    this.isOnline,
    this.backgroundColor,
    this.onTap,
    this.borderWidth = 0,
    this.borderColor,
  });

  final String? imageUrl;
  final String? name;
  final AppAvatarSize size;
  final bool? isOnline;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final double borderWidth;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dimension = size.value;

    Widget avatar;

    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    if (hasImage) {
      avatar = AppImage(
        url: imageUrl!,
        width: dimension,
        height: dimension,
        fit: BoxFit.cover,
        borderRadius: BorderRadius.circular(dimension),
      );
    } else {
      // Initials fallback
      final initials = _initials(name);
      final bgColor = backgroundColor ?? _colorFromName(name, theme);
      avatar = CircleAvatar(
        radius: dimension / 2,
        backgroundColor: bgColor,
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: dimension * 0.36,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    // Border wrapper
    if (borderWidth > 0) {
      avatar = Container(
        width: dimension + borderWidth * 2,
        height: dimension + borderWidth * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor ?? theme.colorScheme.surface,
            width: borderWidth,
          ),
        ),
        child: ClipOval(child: avatar),
      );
    }

    // Online indicator
    if (isOnline != null) {
      avatar = Stack(
        children: [
          avatar,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: dimension * 0.28,
              height: dimension * 0.28,
              decoration: BoxDecoration(
                color: isOnline! ? Colors.green : Colors.grey,
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.surface,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: avatar);
    }
    return avatar;
  }

  String _initials(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }

  Color _colorFromName(String? name, ThemeData theme) {
    if (name == null || name.isEmpty) return theme.colorScheme.primary;
    final index = name.codeUnits.fold(0, (a, b) => a + b) % _avatarColors.length;
    return _avatarColors[index];
  }

  static const List<Color> _avatarColors = [
    Color(0xFF1976D2),
    Color(0xFF388E3C),
    Color(0xFFF57C00),
    Color(0xFFD32F2F),
    Color(0xFF7B1FA2),
    Color(0xFF00838F),
    Color(0xFF558B2F),
    Color(0xFF6D4C41),
  ];
}
