import 'package:flutter/material.dart';

import '../theme/ui_kit_colors.dart';

/// A card with a title, optional subtitle, and a row of action widgets.
class ActionCard extends StatelessWidget {
  const ActionCard({
    super.key,
    required this.title,
    required this.actions,
    this.subtitle,
    this.leadingWidget,
    this.padding,
    this.borderColor,
    this.backgroundColor,
    this.onTap,
  });

  final String title;
  final String? subtitle;

  /// Action widgets (usually buttons) shown in a row at the bottom.
  final List<Widget> actions;

  /// Optional leading widget (e.g. an image or icon container).
  final Widget? leadingWidget;

  final EdgeInsets? padding;
  final Color? borderColor;
  final Color? backgroundColor;

  /// Optional tap on the card body (separate from action taps).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cardContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (leadingWidget != null) ...[
              leadingWidget!,
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: UiKitColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: UiKitColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        if (actions.isNotEmpty) ...[
          const SizedBox(height: 14),
          const Divider(height: 1, color: UiKitColors.grey100),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: actions
                .expand((w) => [w, const SizedBox(width: 8)])
                .toList()
              ..removeLast(),
          ),
        ],
      ],
    );

    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? UiKitColors.surfaceLight,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        border: Border.all(color: borderColor ?? UiKitColors.grey200),
      ),
      child: onTap != null
          ? InkWell(
              onTap: onTap,
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              child: cardContent,
            )
          : cardContent,
    );
  }
}
