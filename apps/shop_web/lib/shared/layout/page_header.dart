/// Standardised page header with title, optional subtitle, breadcrumb, and
/// action buttons.
library;

import 'package:flutter/material.dart';
import 'package:shop_web/shared/layout/breadcrumb.dart';

/// A consistent page header that combines an optional [Breadcrumb], a title
/// row (with right-aligned [actions]), and an optional subtitle below the
/// title.
///
/// Example:
/// ```dart
/// PageHeader(
///   title: 'Bookings',
///   subtitle: 'Manage all customer bookings',
///   breadcrumbs: [
///     BreadcrumbItem(label: 'Home', route: '/'),
///     BreadcrumbItem(label: 'Bookings'),
///   ],
///   actions: [ExportButton(...)],
/// )
/// ```
class PageHeader extends StatelessWidget {
  /// Creates a [PageHeader].
  const PageHeader({
    required this.title,
    this.subtitle,
    this.actions,
    this.breadcrumbs,
    super.key,
  });

  /// The primary page title.
  final String title;

  /// Optional secondary text displayed below the title.
  final String? subtitle;

  /// Widgets placed to the right of the title (e.g. export/action buttons).
  final List<Widget>? actions;

  /// When provided, renders a [Breadcrumb] above the title.
  final List<BreadcrumbItem>? breadcrumbs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (breadcrumbs != null && breadcrumbs!.isNotEmpty) ...[
          Breadcrumb(items: breadcrumbs!),
          const SizedBox(height: 8),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (actions != null && actions!.isNotEmpty) ...[
              const SizedBox(width: 16),
              Wrap(
                spacing: 8,
                children: actions!,
              ),
            ],
          ],
        ),
      ],
    );
  }
}
