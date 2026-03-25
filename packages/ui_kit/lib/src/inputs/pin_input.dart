import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/ui_kit_colors.dart';

/// PIN / OTP input field that renders [length] individual digit boxes.
///
/// Each box auto-focuses the next one as the user types. Supports 4 or 6
/// digit codes; [length] can be any positive integer.
class PinInput extends StatefulWidget {
  const PinInput({
    super.key,
    this.length = 6,
    this.onCompleted,
    this.onChanged,
    this.obscureText = false,
    this.enabled = true,
    this.errorText,
    this.boxSize = 48.0,
    this.boxSpacing = 8.0,
  }) : assert(length > 0, 'length must be > 0');

  /// Number of PIN digits.
  final int length;

  /// Called with the full PIN string once all [length] digits are entered.
  final ValueChanged<String>? onCompleted;

  /// Called on every keystroke with the current (potentially incomplete) PIN.
  final ValueChanged<String>? onChanged;

  /// Replaces digits with bullets when `true`.
  final bool obscureText;

  final bool enabled;

  /// Optional inline error message.
  final String? errorText;

  /// Width and height of each individual box.
  final double boxSize;

  /// Gap between boxes.
  final double boxSpacing;

  @override
  State<PinInput> createState() => _PinInputState();
}

class _PinInputState extends State<PinInput> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _currentPin =>
      _controllers.map((c) => c.text).join();

  void _onChanged(int index, String value) {
    if (value.length > 1) {
      // Handle paste: distribute characters across boxes.
      final chars = value.characters.toList();
      for (var i = 0; i < widget.length && i < chars.length; i++) {
        _controllers[i].text = chars[i];
      }
      final nextEmpty = _controllers.indexWhere((c) => c.text.isEmpty);
      if (nextEmpty == -1) {
        _focusNodes.last.requestFocus();
      } else {
        _focusNodes[nextEmpty].requestFocus();
      }
    } else if (value.isEmpty) {
      // Backspace: move focus back.
      if (index > 0) _focusNodes[index - 1].requestFocus();
    } else {
      // Single character entered: move to next box.
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }

    widget.onChanged?.call(_currentPin);

    if (_currentPin.length == widget.length) {
      widget.onCompleted?.call(_currentPin);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.length, (index) {
            return Padding(
              padding: EdgeInsets.only(
                right: index < widget.length - 1 ? widget.boxSpacing : 0,
              ),
              child: _PinBox(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                obscureText: widget.obscureText,
                enabled: widget.enabled,
                hasError: widget.errorText != null,
                size: widget.boxSize,
                onChanged: (v) => _onChanged(index, v),
              ),
            );
          }),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            widget.errorText!,
            style: const TextStyle(
              fontSize: 12,
              color: UiKitColors.error,
            ),
          ),
        ],
      ],
    );
  }
}

class _PinBox extends StatelessWidget {
  const _PinBox({
    required this.controller,
    required this.focusNode,
    required this.obscureText,
    required this.enabled,
    required this.hasError,
    required this.size,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool obscureText;
  final bool enabled;
  final bool hasError;
  final double size;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        enabled: enabled,
        maxLength: 2, // allow brief >1 for paste detection then trim
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: UiKitColors.textPrimary,
        ),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          filled: true,
          fillColor: enabled ? UiKitColors.grey50 : UiKitColors.grey100,
          border: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(
              color: hasError ? UiKitColors.error : UiKitColors.grey300,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(
              color: hasError ? UiKitColors.error : UiKitColors.grey300,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(
              color: hasError ? UiKitColors.error : UiKitColors.primary,
              width: 1.5,
            ),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
