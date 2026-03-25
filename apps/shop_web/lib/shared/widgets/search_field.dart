/// Debounced search text field.
library;

import 'dart:async';

import 'package:flutter/material.dart';

/// A text field with a search prefix icon, clear suffix button, and
/// debounced [onSearch] callback.
///
/// Prevents excessive callbacks during fast typing by waiting
/// [debounceDuration] (default 500 ms) after the user stops typing.
class SearchField extends StatefulWidget {
  /// Creates a [SearchField].
  const SearchField({
    required this.onSearch,
    this.hintText,
    this.debounceDuration = const Duration(milliseconds: 500),
    super.key,
  });

  /// Called with the trimmed search query after the debounce delay.
  final void Function(String query) onSearch;

  /// Placeholder text shown when the field is empty.
  final String? hintText;

  /// How long to wait after the last keystroke before calling [onSearch].
  final Duration debounceDuration;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(widget.debounceDuration, () {
      widget.onSearch(value.trim());
    });
    // Trigger rebuild so the clear button visibility is updated.
    setState(() {});
  }

  void _clear() {
    _controller.clear();
    _debounce?.cancel();
    widget.onSearch('');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasText = _controller.text.isNotEmpty;

    return TextField(
      controller: _controller,
      onChanged: _onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: widget.hintText ?? 'Search…',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: hasText
            ? IconButton(
                icon: const Icon(Icons.clear_rounded),
                tooltip: 'Clear search',
                onPressed: _clear,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: theme.colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: theme.colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        isDense: true,
      ),
    );
  }
}
