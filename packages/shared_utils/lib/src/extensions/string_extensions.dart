extension StringExtensions on String {
  /// Returns true if the string is a valid email address.
  bool get isValidEmail => RegExp(
        r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
      ).hasMatch(this);

  /// Returns true if the string is a valid 10-digit Indian phone number.
  bool get isValidIndianPhone => RegExp(r'^[6-9]\d{9}$').hasMatch(this);

  /// Returns true if the string is a 6-digit OTP.
  bool get isValidOtp => RegExp(r'^\d{6}$').hasMatch(this);

  /// Capitalises the first letter of each word.
  String get titleCase => split(' ')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
      .join(' ');

  /// Returns null if the string is empty, otherwise returns [this].
  String? get nullIfEmpty => isEmpty ? null : this;

  /// Masks all but the last 4 characters of the string.
  String get masked {
    if (length <= 4) return this;
    return '${'*' * (length - 4)}${substring(length - 4)}';
  }
}

extension NullableStringExtensions on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
}
