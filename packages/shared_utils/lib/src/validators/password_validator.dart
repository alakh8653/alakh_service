/// Represents the relative strength of a password.
enum PasswordStrength {
  /// Very easy to guess; fails most rules.
  weak,

  /// Passes some rules but not all.
  fair,

  /// Passes all required rules.
  strong,

  /// Passes all required rules and is longer than 12 characters.
  veryStrong,
}

/// Validates passwords and measures their strength.
class PasswordValidator {
  PasswordValidator._();

  /// Returns the [PasswordStrength] of [password].
  static PasswordStrength getStrength(String password) {
    final failed = getFailedRules(password);
    final length = password.length;

    if (failed.length >= 3) return PasswordStrength.weak;
    if (failed.isNotEmpty) return PasswordStrength.fair;
    if (length >= 12) return PasswordStrength.veryStrong;
    return PasswordStrength.strong;
  }

  /// Returns an error message when [value] does not meet the requirements,
  /// or `null` when it is valid.
  ///
  /// Parameters let callers customise the requirements.
  static String? validate(
    String? value, {
    int minLength = 8,
    bool requireUppercase = true,
    bool requireDigit = true,
    bool requireSpecial = true,
  }) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    if (requireUppercase && !value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (requireDigit && !value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one digit';
    }
    if (requireSpecial &&
        !value.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  /// Returns the list of human-readable rule descriptions that [password]
  /// currently fails. An empty list means the password passes all default rules.
  static List<String> getFailedRules(String password) {
    final failures = <String>[];

    if (password.length < 8) {
      failures.add('At least 8 characters');
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      failures.add('At least one uppercase letter');
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      failures.add('At least one lowercase letter');
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      failures.add('At least one digit');
    }
    if (!password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) {
      failures.add('At least one special character');
    }
    return failures;
  }
}
