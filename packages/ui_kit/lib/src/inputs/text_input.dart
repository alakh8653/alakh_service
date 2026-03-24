import 'package:flutter/material.dart';

import '../theme/ui_kit_colors.dart';

/// A styled [TextFormField] with label, hint, error, and prefix/suffix support.
class TextInput extends StatelessWidget {
  const TextInput({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.helperText,
    this.obscureText = false,
    this.keyboardType,
    this.prefix,
    this.suffix,
    this.onSuffixTap,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
    this.focusNode,
    this.autofocus = false,
    this.textInputAction,
    this.initialValue,
  });

  final TextEditingController? controller;

  /// Optional floating label above the field.
  final String? label;

  /// Placeholder text shown when field is empty.
  final String? hint;

  /// Inline error message shown below the field.
  final String? errorText;

  /// Helper text shown below the field when there is no error.
  final String? helperText;

  /// When `true`, input characters are replaced with bullets.
  final bool obscureText;

  final TextInputType? keyboardType;

  /// Widget shown at the start (inside) of the input.
  final Widget? prefix;

  /// Widget shown at the end (inside) of the input.
  final Widget? suffix;

  /// Optional tap handler for the suffix widget.
  final VoidCallback? onSuffixTap;

  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  final bool enabled;

  /// When `true`, text cannot be edited (but can be selected/copied).
  final bool readOnly;

  final int? maxLines;
  final int? maxLength;

  /// Form validator function.
  final String? Function(String?)? validator;

  final FocusNode? focusNode;
  final bool autofocus;
  final TextInputAction? textInputAction;
  final String? initialValue;

  @override
  Widget build(BuildContext context) {
    Widget? suffixWidget;
    if (suffix != null) {
      suffixWidget = onSuffixTap != null
          ? GestureDetector(onTap: onSuffixTap, child: suffix)
          : suffix;
    }

    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      enabled: enabled,
      readOnly: readOnly,
      maxLines: maxLines,
      maxLength: maxLength,
      validator: validator,
      focusNode: focusNode,
      autofocus: autofocus,
      textInputAction: textInputAction,
      style: const TextStyle(
        fontSize: 14,
        color: UiKitColors.textPrimary,
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
        helperText: helperText,
        prefixIcon: prefix,
        suffixIcon: suffixWidget,
        counterText: maxLength != null ? null : '',
      ),
    );
  }
}
