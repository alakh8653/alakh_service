import 'package:flutter/material.dart';

/// A reusable form field widget for authentication screens.
class AuthFormField extends StatelessWidget {
  /// Label text displayed above the field.
  final String label;

  /// Hint text shown inside the field when empty.
  final String? hint;

  /// Controller for managing field text.
  final TextEditingController? controller;

  /// Whether the input should be obscured (e.g., for passwords).
  final bool obscureText;

  /// Input type for the text field.
  final TextInputType keyboardType;

  /// Validation function for the field.
  final String? Function(String?)? validator;

  /// Callback triggered when the value changes.
  final ValueChanged<String>? onChanged;

  /// Optional prefix icon.
  final IconData? prefixIcon;

  /// Optional suffix widget (e.g., toggle password visibility).
  final Widget? suffix;

  /// Action to take when the user submits the field.
  final TextInputAction textInputAction;

  /// Callback when the field action button is pressed.
  final VoidCallback? onFieldSubmitted;

  /// Whether the field is enabled.
  final bool enabled;

  const AuthFormField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.prefixIcon,
    this.suffix,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          textInputAction: textInputAction,
          enabled: enabled,
          onFieldSubmitted: onFieldSubmitted != null ? (_) => onFieldSubmitted!() : null,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
            suffix: suffix,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.error),
            ),
            filled: true,
            fillColor: enabled
                ? theme.colorScheme.surface
                : theme.colorScheme.surfaceVariant,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}
