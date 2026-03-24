/// Search bar with debounce, clear button, and filter icon.
library;

import 'dart:async';

import 'package:flutter/material.dart';

/// A search input bar that fires [onSearch] after a debounce delay.
///
/// ### Usage:
/// ```dart
/// AppSearchBar(
///   onSearch: (query) => controller.search(query),
///   onFilterTap: () => _showFilters(),
///   hint: 'Search shops...',
/// )
/// ```
class AppSearchBar extends StatefulWidget {
  const AppSearchBar({
    super.key,
    required this.onSearch,
    this.onFilterTap,
    this.hint = 'Search...',
    this.debounce = const Duration(milliseconds: 400),
    this.initialValue,
    this.autofocus = false,
    this.showFilter = false,
    this.filterBadgeCount = 0,
    this.borderRadius,
    this.controller,
  });

  /// Called with the current query after the debounce period.
  final ValueChanged<String> onSearch;

  /// Tap callback for the filter icon button.
  final VoidCallback? onFilterTap;

  final String hint;
  final Duration debounce;
  final String? initialValue;
  final bool autofocus;

  /// Whether to show the filter icon button.
  final bool showFilter;

  /// Active filter count shown as a badge on the filter button.
  final int filterBadgeCount;

  final BorderRadius? borderRadius;

  /// External controller for the underlying [TextField].
  final TextEditingController? controller;

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late final TextEditingController _controller;
  Timer? _debounceTimer;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
      _hasText = widget.initialValue!.isNotEmpty;
    }
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);

    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounce, () {
      widget.onSearch(_controller.text.trim());
    });
  }

  void _clearSearch() {
    _controller.clear();
    widget.onSearch('');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest
            .withValues(alpha: 0.5),
        borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(
            Icons.search_rounded,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: widget.autofocus,
              decoration: InputDecoration(
                hintText: widget.hint,
                border: InputBorder.none,
                isDense: true,
                hintStyle: TextStyle(
                  color:
                      theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
              style: theme.textTheme.bodyLarge,
              textInputAction: TextInputAction.search,
              onSubmitted: (val) {
                _debounceTimer?.cancel();
                widget.onSearch(val.trim());
              },
            ),
          ),
          if (_hasText)
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: _clearSearch,
              visualDensity: VisualDensity.compact,
            ),
          if (widget.showFilter) ...[
            const VerticalDivider(
              width: 1,
              indent: 10,
              endIndent: 10,
            ),
            Stack(
              alignment: Alignment.topRight,
              children: [
                IconButton(
                  icon: const Icon(Icons.tune_rounded, size: 20),
                  onPressed: widget.onFilterTap,
                  visualDensity: VisualDensity.compact,
                ),
                if (widget.filterBadgeCount > 0)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}
