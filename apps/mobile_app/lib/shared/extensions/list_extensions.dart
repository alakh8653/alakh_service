/// [List] extension methods for grouping, sorting, and querying.
library;

/// Utility helpers on [List<E>].
extension ListExtensions<E> on List<E> {
  // ---------------------------------------------------------------------------
  // Safe access
  // ---------------------------------------------------------------------------

  /// Returns the first element, or `null` if the list is empty.
  E? get firstOrNull => isEmpty ? null : first;

  /// Returns the last element, or `null` if the list is empty.
  E? get lastOrNull => isEmpty ? null : last;

  /// Returns the element at [index], or `null` if out of bounds.
  E? elementAtOrNull(int index) =>
      (index >= 0 && index < length) ? this[index] : null;

  // ---------------------------------------------------------------------------
  // Filtering / deduplication
  // ---------------------------------------------------------------------------

  /// Returns a new list containing only elements that are distinct by [key].
  ///
  /// When multiple elements share the same key, the first occurrence is kept.
  List<E> distinctBy<K>(K Function(E element) key) {
    final seen = <K>{};
    return where((e) => seen.add(key(e))).toList();
  }

  /// Returns a new list with duplicate elements removed (by equality).
  List<E> get distinct => {...this}.toList();

  // ---------------------------------------------------------------------------
  // Sorting
  // ---------------------------------------------------------------------------

  /// Returns a new list sorted by the natural order of [key].
  List<E> sortedBy<K extends Comparable>(K Function(E element) key) =>
      [...this]..sort((a, b) => key(a).compareTo(key(b)));

  /// Returns a new list sorted in descending order of [key].
  List<E> sortedByDescending<K extends Comparable>(
    K Function(E element) key,
  ) =>
      [...this]..sort((a, b) => key(b).compareTo(key(a)));

  // ---------------------------------------------------------------------------
  // Grouping
  // ---------------------------------------------------------------------------

  /// Groups elements by [key], returning a map of `key → list of elements`.
  Map<K, List<E>> groupBy<K>(K Function(E element) key) {
    final result = <K, List<E>>{};
    for (final element in this) {
      result.putIfAbsent(key(element), () => []).add(element);
    }
    return result;
  }

  // ---------------------------------------------------------------------------
  // Chunking
  // ---------------------------------------------------------------------------

  /// Splits the list into sub-lists of at most [size] elements.
  ///
  /// The last chunk may be smaller than [size].
  List<List<E>> chunk(int size) {
    assert(size > 0, 'Chunk size must be positive');
    final chunks = <List<E>>[];
    for (var i = 0; i < length; i += size) {
      chunks.add(sublist(i, (i + size).clamp(0, length)));
    }
    return chunks;
  }

  // ---------------------------------------------------------------------------
  // Aggregation
  // ---------------------------------------------------------------------------

  /// Sums the numeric values returned by [selector].
  double sumBy(num Function(E element) selector) =>
      fold(0, (acc, e) => acc + selector(e).toDouble());

  /// Returns the element with the maximum value of [selector], or `null` if
  /// the list is empty.
  E? maxBy<K extends Comparable>(K Function(E element) selector) {
    if (isEmpty) return null;
    return reduce((a, b) => selector(a).compareTo(selector(b)) >= 0 ? a : b);
  }

  /// Returns the element with the minimum value of [selector], or `null` if
  /// the list is empty.
  E? minBy<K extends Comparable>(K Function(E element) selector) {
    if (isEmpty) return null;
    return reduce((a, b) => selector(a).compareTo(selector(b)) <= 0 ? a : b);
  }

  // ---------------------------------------------------------------------------
  // Interleaving / Joining
  // ---------------------------------------------------------------------------

  /// Returns a new list with [separator] inserted between each element.
  List<E> intersperse(E separator) {
    if (length <= 1) return toList();
    final result = <E>[];
    for (var i = 0; i < length; i++) {
      result.add(this[i]);
      if (i < length - 1) result.add(separator);
    }
    return result;
  }

  // ---------------------------------------------------------------------------
  // Replacement / Update
  // ---------------------------------------------------------------------------

  /// Returns a new list where the first element satisfying [test] is replaced
  /// by [replacement].  If no match is found, the list is returned unchanged.
  List<E> replaceFirstWhere(bool Function(E) test, E replacement) {
    final copy = [...this];
    final index = copy.indexWhere(test);
    if (index != -1) copy[index] = replacement;
    return copy;
  }
}

/// Extensions on [Iterable<E>].
extension IterableExtensions<E> on Iterable<E> {
  /// Returns the first element matching [test], or `null` if none found.
  E? firstOrNullWhere(bool Function(E) test) {
    for (final e in this) {
      if (test(e)) return e;
    }
    return null;
  }
}
