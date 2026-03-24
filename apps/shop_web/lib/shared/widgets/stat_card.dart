/// A card widget that displays a single KPI metric with an optional trend.
library;

import 'package:flutter/material.dart';

/// Displays a labelled metric value alongside an icon and an optional
/// up/down trend indicator.
///
/// Designed for the dashboard overview grid. Adds a subtle elevation
/// animation on web hover.
class StatCard extends StatefulWidget {
  /// Creates a [StatCard].
  const StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.trendPercentage,
    this.trendUp = true,
    super.key,
  });

  /// Short descriptive label (e.g. "Total Bookings").
  final String label;

  /// The formatted metric value (e.g. "1,234" or "₹45,000").
  final String value;

  /// Icon representing the metric category.
  final IconData icon;

  /// Accent colour used for the icon background and trend chip.
  final Color color;

  /// If provided, shows a trend chip with this percentage value.
  final double? trendPercentage;

  /// Whether the trend is positive (up). Ignored when [trendPercentage] is
  /// `null`.
  final bool trendUp;

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_hovered ? 0.12 : 0.06),
              blurRadius: _hovered ? 18 : 8,
              offset: Offset(0, _hovered ? 6 : 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _IconBadge(color: widget.color, icon: widget.icon),
                if (widget.trendPercentage != null)
                  _TrendChip(
                    percentage: widget.trendPercentage!,
                    trendUp: widget.trendUp,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Circular icon badge with a tinted background.
class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.color, required this.icon});

  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}

/// Small chip showing an up or down trend percentage.
class _TrendChip extends StatelessWidget {
  const _TrendChip({required this.percentage, required this.trendUp});

  final double percentage;
  final bool trendUp;

  @override
  Widget build(BuildContext context) {
    final color = trendUp ? Colors.green.shade600 : Colors.red.shade600;
    final icon = trendUp ? Icons.trending_up_rounded : Icons.trending_down_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 2),
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
