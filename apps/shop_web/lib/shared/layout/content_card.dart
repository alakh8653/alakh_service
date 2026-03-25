/// Consistent card container with optional header, title, and actions.
library;

import 'package:flutter/material.dart';

/// A Material 3 styled card that wraps content with consistent padding and an
/// optional header section containing a [title] and [actions].
///
/// ```dart
/// ContentCard(
///   title: 'Recent Bookings',
///   actions: [ExportButton(...)],
///   child: ShopDataTable(...),
/// )
/// ```
class ContentCard extends StatelessWidget {
  /// Creates a [ContentCard].
  const ContentCard({
    required this.child,
    this.title,
    this.actions,
    this.padding,
    super.key,
  });

  /// The main content rendered inside the card body.
  final Widget child;

  /// Optional title shown in the card header.
  final String? title;

  /// Optional widgets placed to the right of the [title] in the header row.
  final List<Widget>? actions;

  /// Padding applied to the content area.  Defaults to 16 px on all sides.
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasHeader = title != null || (actions != null && actions!.isNotEmpty);

    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasHeader) ...[
            _CardHeader(title: title, actions: actions),
            Divider(height: 1, color: colorScheme.outlineVariant),
          ],
          Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({this.title, this.actions});

  final String? title;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (title != null)
            Expanded(
              child: Text(
                title!,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (actions != null && actions!.isNotEmpty)
            Wrap(spacing: 8, children: actions!),
        ],
      ),
    );
  }
}
