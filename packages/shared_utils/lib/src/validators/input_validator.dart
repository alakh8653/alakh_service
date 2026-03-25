/// A chainable, builder-style validator for text input fields.
///
/// Usage:
/// ```dart
/// final validator = InputValidator.build()
///   .required()
///   .minLength(3)
///   .maxLength(50);
///
/// final error = validator.validate(someValue);
/// ```
class InputValidator {
  InputValidator._();

  final List<_ValidationRule> _rules = [];

  /// Creates a new [InputValidator] instance.
  static InputValidator build() => InputValidator._();

  /// Adds a rule that rejects `null` or empty values.
  InputValidator required({String? message}) {
    _rules.add(_ValidationRule(
      (v) => (v == null || v.trim().isEmpty) ? (message ?? 'This field is required') : null,
    ));
    return this;
  }

  /// Adds a rule that rejects values shorter than [min] characters.
  InputValidator minLength(int min, {String? message}) {
    _rules.add(_ValidationRule(
      (v) => (v != null && v.length < min)
          ? (message ?? 'Must be at least $min characters')
          : null,
    ));
    return this;
  }

  /// Adds a rule that rejects values longer than [max] characters.
  InputValidator maxLength(int max, {String? message}) {
    _rules.add(_ValidationRule(
      (v) => (v != null && v.length > max)
          ? (message ?? 'Must be at most $max characters')
          : null,
    ));
    return this;
  }

  /// Adds a rule that rejects values not matching [pattern].
  InputValidator pattern(RegExp pattern, {String? message}) {
    _rules.add(_ValidationRule(
      (v) => (v != null && !pattern.hasMatch(v))
          ? (message ?? 'Invalid format')
          : null,
    ));
    return this;
  }

  /// Runs all registered rules against [value] and returns the first error
  /// message found, or `null` if all rules pass.
  String? validate(String? value) {
    for (final rule in _rules) {
      final error = rule.check(value);
      if (error != null) return error;
    }
    return null;
  }
}

class _ValidationRule {
  const _ValidationRule(this._check);

  final String? Function(String? value) _check;

  String? check(String? value) => _check(value);
}
