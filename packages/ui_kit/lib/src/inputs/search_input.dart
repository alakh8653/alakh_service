import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/ui_kit_colors.dart';
import 'text_input.dart';

/// A [TextInput] variant with a search prefix icon, clear button, and optional
/// debounce support so that [onChanged] is only invoked after [debounceDuration]
/// has elapsed since the last keystroke.
class SearchInput extends StatefulWidget {
  const SearchInput({
    super.key,
    this.controller,
    this.hint = 'Search…',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.debounceDuration = const Duration(milliseconds: 350),
    this.enabled = true,
    this.autofocus = false,
    this.focusNode,
  });

  final TextEditingController? controller;
  final String? hint;

  /// Called with the current query value, debounced by [debounceDuration].
  final ValueChanged<String>? onChanged;

  final ValueChanged<String>? onSubmitted;

  /// Called when the user clears the field.
  final VoidCallback? onClear;

  /// Duration to wait after the last keystroke before calling [onChanged].
  final Duration debounceDuration;
  final bool enabled;
  final bool autofocus;
  final FocusNode? focusNode;

  @override
  State<SearchInput> createState() => _SearchInputState();
}

class _SearchInputState extends State<SearchInput> {
  late final TextEditingController _controller;
  bool _ownsController = false;
  Timer? _debounce;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController();
      _ownsController = true;
    }
    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.removeListener(_onTextChanged);
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);

    _debounce?.cancel();
    _debounce = Timer(widget.debounceDuration, () {
      widget.onChanged?.call(_controller.text);
    });
  }

  void _clearText() {
    _controller.clear();
    widget.onClear?.call();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    return TextInput(
      controller: _controller,
      hint: widget.hint,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      focusNode: widget.focusNode,
      onSubmitted: widget.onSubmitted,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.search,
      prefix: const Icon(Icons.search, size: 20, color: UiKitColors.grey400),
      suffix: _hasText
          ? Icon(Icons.close, size: 18, color: UiKitColors.grey400)
          : null,
      onSuffixTap: _hasText ? _clearText : null,
    );
  }
}
