import 'package:flutter/material.dart';

import '../theme/ui_kit_colors.dart';

/// A centred empty-state illustration with icon, title, optional subtitle, and
/// an optional action widget (e.g. a button to create the first item).
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
    this.iconSize,
    this.iconColor,
    this.titleStyle,
    this.subtitleStyle,
    this.padding,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  /// Size of the icon. Defaults to 72.
  final double? iconSize;

  /// Icon colour. Defaults to [UiKitColors.grey300].
  final Color? iconColor;

  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding ?? const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: iconSize ?? 72,
              color: iconColor ?? UiKitColors.grey300,
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: titleStyle ??
                  const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: UiKitColors.textPrimary,
                  ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: subtitleStyle ??
                    const TextStyle(
                      fontSize: 14,
                      color: UiKitColors.textSecondary,
                      height: 1.5,
                    ),
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
