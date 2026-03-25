import 'package:flutter/material.dart';

import '../theme/ui_kit_colors.dart';

/// Direction of change for the [StatCard] trend indicator.
enum TrendDirection { up, down, neutral }

/// A statistics display card showing a [label], primary [value], and an optional
/// [delta] with a [trend] arrow.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.delta,
    this.trend = TrendDirection.neutral,
    this.icon,
    this.iconColor,
    this.iconBackgroundColor,
    this.valueStyle,
    this.onTap,
    this.padding,
    this.backgroundColor,
    this.borderColor,
  });

  /// Short description of the statistic (e.g. "Total Orders").
  final String label;

  /// The primary metric value displayed prominently (e.g. "1,234").
  final String value;

  /// Change text shown below the value (e.g. "+12%").
  final String? delta;

  /// Whether [delta] represents an increase, decrease, or no change.
  final TrendDirection trend;

  /// Icon shown in the top-right corner.
  final IconData? icon;
  final Color? iconColor;
  final Color? iconBackgroundColor;

  /// Override the [value] text style.
  final TextStyle? valueStyle;

  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final Color? borderColor;

  Color get _trendColor {
    switch (trend) {
      case TrendDirection.up:
        return UiKitColors.success;
      case TrendDirection.down:
        return UiKitColors.error;
      case TrendDirection.neutral:
        return UiKitColors.textSecondary;
    }
  }

  IconData get _trendIcon {
    switch (trend) {
      case TrendDirection.up:
        return Icons.trending_up_rounded;
      case TrendDirection.down:
        return Icons.trending_down_rounded;
      case TrendDirection.neutral:
        return Icons.trending_flat_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: UiKitColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 8),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBackgroundColor ??
                      UiKitColors.primary.withOpacity(0.1),
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: iconColor ?? UiKitColors.primary,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: valueStyle ??
              const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: UiKitColors.textPrimary,
                height: 1.1,
              ),
        ),
        if (delta != null) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_trendIcon, size: 14, color: _trendColor),
              const SizedBox(width: 2),
              Text(
                delta!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _trendColor,
                ),
              ),
            ],
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
              child: content,
            )
          : content,
    );
  }
}
