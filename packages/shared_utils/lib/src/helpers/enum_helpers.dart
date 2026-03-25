import '../helpers/string_helpers.dart';

/// Utility functions for working with Dart enums.
class EnumHelpers {
  EnumHelpers._();

  /// Attempts to find an enum value in [values] whose name matches [name].
  ///
  /// Returns `null` when no match is found or when [name] is `null`.
  static T? tryParse<T extends Enum>(List<T> values, String? name) {
    if (name == null) return null;
    for (final v in values) {
      if (v.name == name) return v;
    }
    return null;
  }

  /// Finds an enum value in [values] whose name matches [name].
  ///
  /// Returns [fallback] when no match is found.
  /// Throws an [ArgumentError] when no match is found and no [fallback] is
  /// provided.
  static T parse<T extends Enum>(
    List<T> values,
    String name, {
    T? fallback,
  }) {
    final result = tryParse(values, name);
    if (result != null) return result;
    if (fallback != null) return fallback;
    throw ArgumentError.value(name, 'name', 'No enum value with that name');
  }

  /// Converts an enum value's name to a human-readable display string.
  ///
  /// Converts camelCase names to space-separated title-case words.
  ///
  /// Example: `toDisplayName(MyEnum.shopOwner)` → `"Shop Owner"`
  static String toDisplayName(Enum value) =>
      StringHelpers.camelToWords(value.name);

  /// Returns a [Map] from each enum value to its display name.
  static Map<T, String> toDisplayMap<T extends Enum>(List<T> values) => {
        for (final v in values) v: toDisplayName(v),
      };
}
