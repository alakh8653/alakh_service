/// General-purpose list utility functions.
class ListHelpers {
  ListHelpers._();

  /// Groups the elements of [list] by the key returned by [keyOf].
  ///
  /// Returns a [Map] from each distinct key to the list of elements that share
  /// that key.
  static Map<K, List<T>> groupBy<T, K>(List<T> list, K Function(T) keyOf) {
    final result = <K, List<T>>{};
    for (final item in list) {
      result.putIfAbsent(keyOf(item), () => []).add(item);
    }
    return result;
  }

  /// Splits [list] into sub-lists of at most [size] elements.
  static List<List<T>> chunk<T>(List<T> list, int size) {
    assert(size > 0, 'chunk size must be positive');
    final chunks = <List<T>>[];
    for (var i = 0; i < list.length; i += size) {
      chunks.add(list.sublist(i, (i + size).clamp(0, list.length)));
    }
    return chunks;
  }

  /// Returns a copy of [list] with duplicate elements removed, where
  /// duplicates are detected by comparing the key returned by [keyOf].
  ///
  /// Preserves the order of first occurrences.
  static List<T> distinctBy<T, K>(List<T> list, K Function(T) keyOf) {
    final seen = <K>{};
    return list.where((item) => seen.add(keyOf(item))).toList();
  }

  /// Returns a copy of [list] sorted by the key returned by [keyOf].
  ///
  /// Set [descending] to `true` to reverse the order.
  static List<T> sortedBy<T, K extends Comparable>(
    List<T> list,
    K Function(T) keyOf, {
    bool descending = false,
  }) {
    final copy = list.toList();
    copy.sort((a, b) {
      final cmp = keyOf(a).compareTo(keyOf(b));
      return descending ? -cmp : cmp;
    });
    return copy;
  }

  /// Returns the first element of [list] that satisfies [test], or `null`
  /// when no such element exists.
  static T? firstWhereOrNull<T>(List<T> list, bool Function(T) test) {
    for (final item in list) {
      if (test(item)) return item;
    }
    return null;
  }

  /// Flattens a list of lists into a single list.
  static List<T> flatten<T>(List<List<T>> lists) =>
      [for (final inner in lists) ...inner];

  /// Interleaves the elements of [a] and [b] into a single list.
  ///
  /// When the lists have different lengths the remaining elements from the
  /// longer list are appended at the end.
  ///
  /// Example: `interleave([1,2,3], [4,5])` → `[1,4,2,5,3]`
  static List<T> interleave<T>(List<T> a, List<T> b) {
    final result = <T>[];
    final limit = a.length < b.length ? a.length : b.length;
    for (var i = 0; i < limit; i++) {
      result
        ..add(a[i])
        ..add(b[i]);
    }
    if (a.length > limit) result.addAll(a.sublist(limit));
    if (b.length > limit) result.addAll(b.sublist(limit));
    return result;
  }
}
