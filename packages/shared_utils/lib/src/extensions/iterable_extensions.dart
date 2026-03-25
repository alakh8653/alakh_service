/// Convenient extension methods on [Iterable].
extension IterableExtensions<T> on Iterable<T> {
  /// Returns the first element satisfying [test], or `null` when none exists.
  T? firstWhereOrNull(bool Function(T) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }

  /// Groups elements by the key returned by [keyOf].
  Map<K, List<T>> groupBy<K>(K Function(T) keyOf) {
    final result = <K, List<T>>{};
    for (final item in this) {
      result.putIfAbsent(keyOf(item), () => []).add(item);
    }
    return result;
  }

  /// Returns an iterable with duplicate elements removed, where duplicates
  /// are detected by comparing the key returned by [keyOf].
  Iterable<T> distinctBy<K>(K Function(T) keyOf) {
    final seen = <K>{};
    return where((item) => seen.add(keyOf(item)));
  }

  /// Returns a sorted [List] of the elements in this iterable, ordered by
  /// the [Comparable] key returned by [keyOf].
  List<T> sortedBy<K extends Comparable>(K Function(T) keyOf,
      {bool descending = false}) {
    final list = toList();
    list.sort((a, b) {
      final cmp = keyOf(a).compareTo(keyOf(b));
      return descending ? -cmp : cmp;
    });
    return list;
  }

  /// Splits this iterable into consecutive sub-lists of at most [size]
  /// elements.
  List<List<T>> chunk(int size) {
    assert(size > 0, 'chunk size must be positive');
    final list = toList();
    final chunks = <List<T>>[];
    for (var i = 0; i < list.length; i += size) {
      chunks.add(list.sublist(i, (i + size).clamp(0, list.length)));
    }
    return chunks;
  }

  /// Returns the sum of the numeric values returned by [selector].
  ///
  /// Returns `0` for an empty iterable.
  num sumBy(num Function(T) selector) =>
      fold<num>(0, (sum, item) => sum + selector(item));
}
