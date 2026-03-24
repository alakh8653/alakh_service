/// Composable validation rule builder.
library;

import 'form_validators.dart';

/// A chain of [FormFieldValidator] functions applied in sequence.
///
/// Stops at the first validation error and returns its message.
///
/// ### Usage
/// ```dart
/// final validator = ValidationRules<String>()
///     .add(FormValidators.required())
///     .add(FormValidators.email())
///     .build();
/// ```
class ValidationRules<T> {
  final List<FormFieldValidator<T>> _rules = [];

  /// Appends a validation rule to the chain and returns `this` for fluency.
  ValidationRules<T> add(FormFieldValidator<T> rule) {
    _rules.add(rule);
    return this;
  }

  /// Builds a single [FormFieldValidator] that runs all rules in order.
  ///
  /// Returns the first error message encountered, or `null` if all pass.
  FormFieldValidator<T> build() {
    return (T? value) {
      for (final rule in _rules) {
        final error = rule(value);
        if (error != null) return error;
      }
      return null;
    };
  }

  // ---------------------------------------------------------------------------
  // Convenience factory constructors for the most common combinations
  // ---------------------------------------------------------------------------

  /// Required + email validation.
  static FormFieldValidator<String> requiredEmail() =>
      ValidationRules<String>()
          .add(FormValidators.required())
          .add(FormValidators.email())
          .build();

  /// Required + phone validation.
  static FormFieldValidator<String> requiredPhone() =>
      ValidationRules<String>()
          .add(FormValidators.required())
          .add(FormValidators.phone())
          .build();

  /// Required + strong password validation.
  static FormFieldValidator<String> requiredStrongPassword() =>
      ValidationRules<String>()
          .add(FormValidators.required())
          .add(FormValidators.strongPassword())
          .build();

  /// Required + min/max length validation.
  static FormFieldValidator<String> requiredLength(int min, int max) =>
      ValidationRules<String>()
          .add(FormValidators.required())
          .add(FormValidators.lengthRange(min, max))
          .build();

  /// Required + numeric validation.
  static FormFieldValidator<String> requiredNumeric() =>
      ValidationRules<String>()
          .add(FormValidators.required())
          .add(FormValidators.numeric())
          .build();
}
