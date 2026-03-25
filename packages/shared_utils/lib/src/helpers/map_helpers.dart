/// General-purpose map utility functions.
class MapHelpers {
  MapHelpers._();

  /// Recursively merges [override] into [base].
  ///
  /// When both maps contain the same key and both values are
  /// `Map<String, dynamic>`, the values are merged recursively.
  /// Otherwise the value from [override] takes precedence.
  static Map<String, dynamic> deepMerge(
    Map<String, dynamic> base,
    Map<String, dynamic> override,
  ) {
    final result = Map<String, dynamic>.from(base);
    for (final entry in override.entries) {
      final baseValue = result[entry.key];
      final overrideValue = entry.value;
      if (baseValue is Map<String, dynamic> &&
          overrideValue is Map<String, dynamic>) {
        result[entry.key] = deepMerge(baseValue, overrideValue);
      } else {
        result[entry.key] = overrideValue;
      }
    }
    return result;
  }

  /// Returns a new map containing only the entries from [map] whose values
  /// are non-null.
  static Map<K, V> filterNullValues<K, V>(Map<K, V?> map) {
    return {
      for (final entry in map.entries)
        if (entry.value != null) entry.key: entry.value as V,
    };
  }

  /// Returns a new map containing only the entries from [map] whose keys are
  /// present in [keys].
  static Map<K, V> pick<K, V>(Map<K, V> map, List<K> keys) {
    return {
      for (final key in keys)
        if (map.containsKey(key)) key: map[key] as V,
    };
  }

  /// Returns a new map containing all entries from [map] except those whose
  /// keys are present in [keys].
  static Map<K, V> omit<K, V>(Map<K, V> map, List<K> keys) {
    final omitSet = keys.toSet();
    return {
      for (final entry in map.entries)
        if (!omitSet.contains(entry.key)) entry.key: entry.value,
    };
  }

  /// Creates a [Map] from a list of [MapEntry] objects.
  static Map<K, V> fromEntries<K, V>(List<MapEntry<K, V>> entries) =>
      Map.fromEntries(entries);
}
