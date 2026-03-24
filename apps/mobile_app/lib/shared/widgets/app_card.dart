/// Reusable card widget with shadow, border radius, and tap callback.
library;

import 'package:flutter/material.dart';

/// A styled card container with consistent shadow, border radius, padding, and
/// an optional tap callback.
///
/// ### Usage:
/// ```dart
/// AppCard(
///   onTap: () => context.push(DetailScreen()),
///   child: ListTile(title: Text('Item')),
/// )
/// ```
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding,
    this.margin,
    this.color,
    this.borderRadius,
    this.elevation,
    this.shadowColor,
    this.border,
    this.clipBehavior = Clip.antiAlias,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final BorderRadius? borderRadius;
  final double? elevation;
  final Color? shadowColor;
  final BoxBorder? border;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = borderRadius ?? BorderRadius.circular(12);

    Widget content = child;
    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Material(
        color: color ?? theme.colorScheme.surface,
        elevation: elevation ?? 2,
        shadowColor: shadowColor ?? Colors.black.withValues(alpha: 0.08),
        borderRadius: radius,
        clipBehavior: clipBehavior,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: radius,
          child: content,
        ),
      ),
    );
  }
}
