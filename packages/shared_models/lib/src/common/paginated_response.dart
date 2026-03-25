/// A generic wrapper for paginated API list responses.
///
/// [T] is the type of each item in the page.
class PaginatedResponse<T> {
  /// The items on this page.
  final List<T> items;

  /// Total number of items across all pages.
  final int total;

  /// Current 1-based page number.
  final int page;

  /// Maximum number of items returned per page.
  final int perPage;

  /// Whether there are additional pages after this one.
  final bool hasMore;

  const PaginatedResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.perPage,
    required this.hasMore,
  });

  /// Creates a [PaginatedResponse] from a JSON map.
  ///
  /// [fromJsonT] is used to deserialize each item in the `items` list.
  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      PaginatedResponse(
        items: (json['items'] as List<dynamic>).map(fromJsonT).toList(),
        total: json['total'] as int,
        page: json['page'] as int,
        perPage: json['perPage'] as int,
        hasMore: json['hasMore'] as bool,
      );

  /// Converts this instance to a JSON map.
  ///
  /// [toJsonT] is used to serialize each item.
  Map<String, dynamic> toJson(Object? Function(T item) toJsonT) => {
        'items': items.map(toJsonT).toList(),
        'total': total,
        'page': page,
        'perPage': perPage,
        'hasMore': hasMore,
      };

  /// Returns a copy with optionally overridden fields.
  PaginatedResponse<T> copyWith({
    List<T>? items,
    int? total,
    int? page,
    int? perPage,
    bool? hasMore,
  }) =>
      PaginatedResponse(
        items: items ?? this.items,
        total: total ?? this.total,
        page: page ?? this.page,
        perPage: perPage ?? this.perPage,
        hasMore: hasMore ?? this.hasMore,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaginatedResponse<T> &&
          _listEquals(items, other.items) &&
          total == other.total &&
          page == other.page &&
          perPage == other.perPage &&
          hasMore == other.hasMore;

  @override
  int get hashCode => Object.hash(
        Object.hashAll(items),
        total,
        page,
        perPage,
        hasMore,
      );

  @override
  String toString() =>
      'PaginatedResponse(page: $page, perPage: $perPage, total: $total, '
      'hasMore: $hasMore, items: $items)';

  static bool _listEquals<E>(List<E> a, List<E> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
