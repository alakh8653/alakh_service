import 'package:flutter/material.dart';

import '../theme/ui_kit_colors.dart';
import '../theme/ui_kit_shadows.dart';

/// A general-purpose information card with an icon, title, optional subtitle,
/// and an optional trailing widget.
class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.iconBackgroundColor,
    this.trailing,
    this.onTap,
    this.padding,
    this.elevation,
    this.borderColor,
  });

  final String title;
  final String? subtitle;

  /// Icon shown in a coloured circle on the leading side.
  final IconData? icon;
  final Color? iconColor;
  final Color? iconBackgroundColor;

  /// Widget shown on the trailing side (e.g. an arrow or action button).
  final Widget? trailing;

  final VoidCallback? onTap;
  final EdgeInsets? padding;

  /// When non-null, uses a [BoxShadow] instead of a border.
  final double? elevation;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBackgroundColor ?? UiKitColors.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: Icon(
              icon,
              size: 20,
              color: iconColor ?? UiKitColors.primary,
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: UiKitColors.textPrimary,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: UiKitColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          trailing!,
        ],
      ],
    );

    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: UiKitColors.surfaceLight,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        border: elevation == null
            ? Border.all(color: borderColor ?? UiKitColors.grey200)
            : null,
        boxShadow: elevation != null ? UiKitShadows.shadowMd : null,
      ),
      child: onTap != null
          ? InkWell(
              onTap: onTap,
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              child: content,
            )
          : content,
    );
  }
}
