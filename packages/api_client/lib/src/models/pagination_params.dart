import 'package:equatable/equatable.dart';

/// Parameters used to request a paginated list from the API.
///
/// Call [toQueryParams] to convert this object into a query-parameter map
/// that can be passed directly to Dio.
class PaginationParams extends Equatable {
  /// The 1-based page number to request.
  final int page;

  /// The maximum number of items per page.
  final int perPage;

  /// The field name to sort results by, or `null` for the default ordering.
  final String? sortBy;

  /// The sort direction: `'asc'` (ascending) or `'desc'` (descending).
  final String sortOrder;

  const PaginationParams({
    this.page = 1,
    this.perPage = 20,
    this.sortBy,
    this.sortOrder = 'asc',
  })  : assert(page >= 1, 'page must be >= 1'),
        assert(perPage >= 1, 'perPage must be >= 1'),
        assert(
          sortOrder == 'asc' || sortOrder == 'desc',
          "sortOrder must be 'asc' or 'desc'",
        );

  /// Returns a map suitable for use as Dio query parameters.
  Map<String, dynamic> toQueryParams() {
    return {
      'page': page,
      'per_page': perPage,
      if (sortBy != null) 'sort_by': sortBy,
      'sort_order': sortOrder,
    };
  }

  /// Returns a copy of this object with the given fields replaced.
  PaginationParams copyWith({
    int? page,
    int? perPage,
    String? sortBy,
    String? sortOrder,
  }) {
    return PaginationParams(
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  /// Returns a new [PaginationParams] pointing to the next page.
  PaginationParams nextPage() => copyWith(page: page + 1);

  /// Returns a new [PaginationParams] pointing to the previous page,
  /// clamped to page 1.
  PaginationParams previousPage() => copyWith(page: page > 1 ? page - 1 : 1);

  @override
  List<Object?> get props => [page, perPage, sortBy, sortOrder];
}
