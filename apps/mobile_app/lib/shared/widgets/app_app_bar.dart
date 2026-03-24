/// Custom AppBar with back button, title, actions, and search mode.
library;

import 'package:flutter/material.dart';

/// A reusable [PreferredSizeWidget] that wraps [AppBar] with consistent
/// styling and an optional inline search mode.
///
/// ### Usage:
/// ```dart
/// AppAppBar(
///   title: 'Bookings',
///   actions: [
///     IconButton(icon: const Icon(Icons.search), onPressed: _toggleSearch),
///   ],
/// )
/// ```
class AppAppBar extends StatefulWidget implements PreferredSizeWidget {
  const AppAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.showSearchMode = false,
    this.onSearchChanged,
    this.onSearchClose,
    this.searchHint = 'Search...',
    this.centerTitle,
    this.backgroundColor,
    this.elevation,
    this.bottom,
  });

  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;

  /// When `true`, renders a search text field instead of the title.
  final bool showSearchMode;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSearchClose;
  final String searchHint;

  final bool? centerTitle;
  final Color? backgroundColor;
  final double? elevation;
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0),
      );

  @override
  State<AppAppBar> createState() => _AppAppBarState();
}

class _AppAppBarState extends State<AppAppBar> {
  late final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget titleWidget;
    List<Widget> actions;

    if (widget.showSearchMode) {
      titleWidget = TextField(
        controller: _searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: widget.searchHint,
          border: InputBorder.none,
          hintStyle: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        style: theme.textTheme.bodyLarge,
        onChanged: widget.onSearchChanged,
      );
      actions = [
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            _searchController.clear();
            widget.onSearchClose?.call();
          },
        ),
      ];
    } else {
      titleWidget = widget.titleWidget ??
          (widget.title != null ? Text(widget.title!) : const SizedBox.shrink());
      actions = widget.actions ?? [];
    }

    return AppBar(
      leading: widget.leading,
      automaticallyImplyLeading: widget.automaticallyImplyLeading,
      title: titleWidget,
      actions: actions,
      centerTitle: widget.centerTitle,
      backgroundColor: widget.backgroundColor,
      elevation: widget.elevation ?? 0,
      scrolledUnderElevation: widget.elevation ?? 2,
      bottom: widget.bottom,
    );
  }
}
