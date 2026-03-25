import 'dart:async';
import 'package:flutter/material.dart';

class AdminSearchField extends StatefulWidget {
  final String? hint;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmit;
  final TextEditingController? controller;
  final bool autofocus;
  final VoidCallback? onClear;

  const AdminSearchField({
    super.key,
    this.hint,
    this.onChanged,
    this.onSubmit,
    this.controller,
    this.autofocus = false,
    this.onClear,
  });

  @override
  State<AdminSearchField> createState() => _AdminSearchFieldState();
}

class _AdminSearchFieldState extends State<AdminSearchField> {
  late final TextEditingController _controller;
  Timer? _debounce;
  bool _hasText = false;

  static const _debounceDuration = Duration(milliseconds: 400);

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onControllerChanged);
    }
    super.dispose();
  }

  void _onControllerChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(_debounceDuration, () {
      widget.onChanged?.call(value);
    });
  }

  void _onClear() {
    _controller.clear();
    widget.onChanged?.call('');
    widget.onClear?.call();
    setState(() => _hasText = false);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      autofocus: widget.autofocus,
      onChanged: _onChanged,
      onSubmitted: widget.onSubmit,
      style: const TextStyle(
        color: Color(0xFFC9D1D9),
        fontSize: 13,
      ),
      decoration: InputDecoration(
        hintText: widget.hint ?? 'Search...',
        hintStyle: const TextStyle(color: Color(0xFF8B949E)),
        prefixIcon: const Icon(
          Icons.search,
          size: 18,
          color: Color(0xFF8B949E),
        ),
        suffixIcon: _hasText
            ? IconButton(
                icon: const Icon(Icons.clear, size: 16),
                onPressed: _onClear,
                color: const Color(0xFF8B949E),
                tooltip: 'Clear',
              )
            : null,
        filled: true,
        fillColor: const Color(0xFF21262D),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFF30363D)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFF30363D)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFF1F6FEB), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        isDense: true,
      ),
    );
  }
}
