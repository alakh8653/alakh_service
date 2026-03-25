/// Notification / count badge widget.
library;

import 'package:flutter/material.dart';

/// Overlays a numeric count (or a dot) badge on the top-right corner of its
/// [child] widget.
///
/// When [count] is 0 and [showWhenZero] is `false` (default), the badge is
/// hidden.  A [count] above [maxCount] displays `"${maxCount}+"`.
///
/// ### Usage:
/// ```dart
/// AppBadge(
///   count: unreadCount,
///   child: const Icon(Icons.notifications_outlined),
/// )
/// ```
class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.child,
    this.count,
    this.showDot = false,
    this.showWhenZero = false,
    this.maxCount = 99,
    this.color,
    this.textColor,
    this.size = 18,
  });

  final Widget child;

  /// The number to display inside the badge. When `null`, the badge is only
  /// shown if [showDot] is `true`.
  final int? count;

  /// When `true`, shows a small dot badge regardless of [count].
  final bool showDot;

  /// When `true`, shows the badge even when [count] is 0.
  final bool showWhenZero;

  /// Counts above this value are displayed as `"${maxCount}+"`.
  final int maxCount;

  /// Badge background colour (defaults to the error colour).
  final Color? color;

  final Color? textColor;

  /// Badge circle diameter.
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final badgeColor = color ?? theme.colorScheme.error;

    final shouldShow = showDot ||
        (count != null && (count! > 0 || showWhenZero));

    if (!shouldShow) return child;

    final label = showDot
        ? null
        : count! > maxCount
            ? '$maxCount+'
            : '$count';

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: -4,
          right: -4,
          child: Container(
            constraints: BoxConstraints(
              minWidth: showDot ? size * 0.5 : size,
              minHeight: showDot ? size * 0.5 : size,
            ),
            padding: showDot
                ? EdgeInsets.zero
                : const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(size),
              border: Border.all(
                color: theme.colorScheme.surface,
                width: 1.5,
              ),
            ),
            child: showDot
                ? null
                : Center(
                    child: Text(
                      label!,
                      style: TextStyle(
                        color: textColor ?? Colors.white,
                        fontSize: size * 0.6,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
