/// Empty state widget with icon, title, subtitle, and optional action button.
library;

import 'package:flutter/material.dart';

/// Displays an empty state screen with an illustration area, title, subtitle,
/// and an optional action button.
///
/// ### Usage:
/// ```dart
/// AppEmptyState(
///   icon: Icons.search_off_outlined,
///   title: 'No results found',
///   subtitle: 'Try different search terms.',
///   actionLabel: 'Clear filters',
///   onAction: _clearFilters,
/// )
/// ```
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    this.icon,
    this.image,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.iconSize = 80,
    this.iconColor,
    this.padding,
  });

  /// A Material icon to display (ignored if [image] is provided).
  final IconData? icon;

  /// An image widget to display instead of [icon].
  final Widget? image;

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final double iconSize;
  final Color? iconColor;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: padding ?? const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Illustration
            if (image != null)
              image!
            else if (icon != null)
              Icon(
                icon,
                size: iconSize,
                color: iconColor ??
                    theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),

            const SizedBox(height: 24),

            // Title
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),

            // Subtitle
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // Action button
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              FilledButton.tonal(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
