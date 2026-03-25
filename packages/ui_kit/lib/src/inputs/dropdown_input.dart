import 'package:flutter/material.dart';

import '../theme/ui_kit_colors.dart';

/// A generic dropdown field backed by [DropdownButtonFormField].
///
/// [T] is the value type of each [DropdownMenuItem].
class DropdownInput<T> extends StatelessWidget {
  const DropdownInput({
    super.key,
    required this.items,
    this.value,
    this.onChanged,
    this.label,
    this.hint,
    this.errorText,
    this.helperText,
    this.enabled = true,
    this.validator,
    this.prefixIcon,
  });

  /// Currently selected value (can be `null` if nothing selected).
  final T? value;

  /// The list of selectable items.
  final List<DropdownMenuItem<T>> items;

  /// Called when the user selects an item.
  final ValueChanged<T?>? onChanged;

  /// Floating label above the field.
  final String? label;

  /// Hint shown when no item is selected.
  final String? hint;

  /// Inline error message.
  final String? errorText;

  /// Helper text shown below the field when there is no error.
  final String? helperText;

  final bool enabled;

  /// Optional form validator.
  final String? Function(T?)? validator;

  /// Optional icon shown inside the field start.
  final IconData? prefixIcon;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: enabled ? onChanged : null,
      validator: validator,
      isExpanded: true,
      style: const TextStyle(
        fontSize: 14,
        color: UiKitColors.textPrimary,
        fontWeight: FontWeight.w400,
      ),
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: UiKitColors.grey400,
        size: 20,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
        helperText: helperText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        filled: true,
        fillColor: enabled ? UiKitColors.grey50 : UiKitColors.grey100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: UiKitColors.grey300),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: UiKitColors.grey300),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: UiKitColors.primary, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: UiKitColors.error),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: UiKitColors.error, width: 1.5),
        ),
      ),
    );
  }
}
