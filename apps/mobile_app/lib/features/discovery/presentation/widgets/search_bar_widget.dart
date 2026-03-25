import 'package:flutter/material.dart';

/// A customised search bar with optional recent-search suggestions.
class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({
    super.key,
    required this.onSubmitted,
    this.onChanged,
    this.recentSearches = const [],
    this.initialValue = '',
    this.hintText = 'Search services or shops…',
  });

  final void Function(String query) onSubmitted;
  final void Function(String query)? onChanged;
  final List<String> recentSearches;
  final String initialValue;
  final String hintText;

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late final TextEditingController _controller;
  final FocusNode _focus = FocusNode();
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _focus.addListener(() {
      setState(() => _showSuggestions = _focus.hasFocus);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _submit(String query) {
    _focus.unfocus();
    if (query.trim().isEmpty) return;
    widget.onSubmitted(query.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _controller,
          focusNode: _focus,
          textInputAction: TextInputAction.search,
          onSubmitted: _submit,
          onChanged: (v) {
            setState(() {});
            widget.onChanged?.call(v);
          },
          decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                      setState(() {});
                      widget.onChanged?.call('');
                    },
                  )
                : null,
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        if (_showSuggestions && widget.recentSearches.isNotEmpty)
          _SuggestionsList(
            searches: widget.recentSearches,
            onSelect: (q) {
              _controller.text = q;
              _submit(q);
            },
          ),
      ],
    );
  }
}

class _SuggestionsList extends StatelessWidget {
  const _SuggestionsList({required this.searches, required this.onSelect});

  final List<String> searches;
  final void Function(String) onSelect;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(8),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: searches.take(5).length,
        itemBuilder: (ctx, i) {
          final query = searches[i];
          return ListTile(
            dense: true,
            leading: const Icon(Icons.history, size: 18),
            title: Text(query),
            onTap: () => onSelect(query),
          );
        },
      ),
    );
  }
}
