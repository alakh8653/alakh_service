/// String extension methods for common transformations and checks.
library;

/// Useful helpers on [String] and [String?].
extension StringExtensions on String {
  // ---------------------------------------------------------------------------
  // Case
  // ---------------------------------------------------------------------------

  /// Capitalises the first letter and lower-cases the rest.
  String get capitalised =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1).toLowerCase()}';

  /// Capitalises the first letter of every word (title case).
  String get titleCase => split(' ')
      .map((word) => word.isEmpty ? word : word.capitalised)
      .join(' ');

  /// Converts `camelCase` or `PascalCase` to `Title Case` with spaces.
  String get camelToTitleCase =>
      replaceAllMapped(RegExp(r'(?<=[a-z])([A-Z])'), (m) => ' ${m[1]}!')
          .replaceAll('!', '')
          .capitalised;

  // ---------------------------------------------------------------------------
  // Slug / URL
  // ---------------------------------------------------------------------------

  /// Converts a string to a URL-safe slug.
  ///
  /// Example: `"Hello World!"` → `"hello-world"`
  String get toSlug => toLowerCase()
      .trim()
      .replaceAll(RegExp(r'[^\w\s-]'), '')
      .replaceAll(RegExp(r'[\s_]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');

  // ---------------------------------------------------------------------------
  // Truncation
  // ---------------------------------------------------------------------------

  /// Truncates the string to [maxLength] characters and appends [ellipsis] if
  /// the string was longer.
  String truncate(int maxLength, {String ellipsis = '...'}) =>
      length <= maxLength ? this : '${substring(0, maxLength)}$ellipsis';

  // ---------------------------------------------------------------------------
  // Validation helpers
  // ---------------------------------------------------------------------------

  /// Returns `true` if the string is a valid email address.
  bool get isEmail =>
      RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$')
          .hasMatch(trim());

  /// Returns `true` if the string is a valid Indian mobile number.
  bool get isPhone =>
      RegExp(r'^(?:\+91|0)?[6-9]\d{9}$').hasMatch(trim());

  /// Returns `true` if the string contains only digits.
  bool get isNumeric => RegExp(r'^\d+$').hasMatch(trim());

  /// Returns `true` if the string is null or empty after trimming.
  bool get isBlank => trim().isEmpty;

  /// Returns `true` if the string has at least one non-whitespace character.
  bool get isNotBlank => !isBlank;

  // ---------------------------------------------------------------------------
  // HTML
  // ---------------------------------------------------------------------------

  /// Strips all HTML tags from the string.
  String get removeHtml => replaceAll(RegExp(r'<[^>]*>'), '');

  // ---------------------------------------------------------------------------
  // Formatting
  // ---------------------------------------------------------------------------

  /// Returns the initials (up to [count] letters) from the string.
  ///
  /// Example: `"John Doe"` → `"JD"`, `"Alice"` → `"A"`
  String initials({int count = 2}) {
    final words = trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    return words
        .take(count)
        .map((w) => w[0].toUpperCase())
        .join();
  }

  /// Masks all but the last [visible] characters with [mask].
  ///
  /// Example: `"9876543210".mask(4)` → `"******3210"`
  String mask(int visible, {String mask = '*'}) {
    if (length <= visible) return this;
    return mask * (length - visible) + substring(length - visible);
  }

  /// Converts a numeric string representing a file size in bytes to a
  /// human-readable string (e.g. `"1.2 MB"`).
  String get asFileSize {
    final bytes = int.tryParse(trim());
    if (bytes == null) return this;
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Wraps the string in double-quotes.
  String get quoted => '"$this"';
}

/// Nullable string extensions.
extension NullableStringExtensions on String? {
  /// Returns `true` if the value is `null`, empty, or only whitespace.
  bool get isNullOrBlank => this == null || this!.trim().isEmpty;

  /// Returns the value or [fallback] when null/blank.
  String orDefault([String fallback = '']) =>
      (isNullOrBlank) ? fallback : this!;
}
