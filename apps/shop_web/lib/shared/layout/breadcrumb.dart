/// Breadcrumb navigation trail widget.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A single crumb in a [Breadcrumb] trail.
class BreadcrumbItem {
  /// Creates a [BreadcrumbItem].
  const BreadcrumbItem({
    required this.label,
    this.route,
  });

  /// Display text for this crumb.
  final String label;

  /// GoRouter path to navigate to when tapped.  Set to `null` for the
  /// current (last) page — it will be rendered as plain non-clickable text.
  final String? route;
}

/// A horizontal breadcrumb trail showing the current navigation path.
///
/// Each item except the last is rendered as a tappable link that navigates
/// to [BreadcrumbItem.route] using [GoRouter].  The last item is displayed
/// as plain text representing the current page.
class Breadcrumb extends StatelessWidget {
  /// Creates a [Breadcrumb].
  const Breadcrumb({
    required this.items,
    super.key,
  });

  /// Ordered list of breadcrumb items from root to current page.
  final List<BreadcrumbItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final widgets = <Widget>[];

    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final isLast = i == items.length - 1;

      if (isLast) {
        widgets.add(
          Text(
            item.label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      } else {
        widgets.add(
          InkWell(
            onTap: item.route != null ? () => context.go(item.route!) : null,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
              child: Text(
                item.label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  decoration: TextDecoration.underline,
                  decorationColor: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
        );
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              Icons.chevron_right_rounded,
              size: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        );
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: widgets,
    );
  }
}
