/// Domain entity that encapsulates all active booking filter/sort/page state.
library;

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Passed to use-cases and through the BLoC to drive booking list queries.
class BookingFilters extends Equatable {
  const BookingFilters({
    this.status,
    this.dateRange,
    this.staffId,
    this.searchQuery,
    this.page = 1,
    this.pageSize = 20,
    this.sortBy = 'booking_date',
    this.sortAsc = false,
  });

  /// Factory returning filters with no active constraints applied.
  factory BookingFilters.initial() => const BookingFilters();

  /// If set, only bookings with this status are included.
  final String? status;

  /// Optional inclusive date range filter.
  final DateTimeRange? dateRange;

  /// If set, only bookings assigned to this staff member are shown.
  final String? staffId;

  /// Free-text search applied to customer name / service name.
  final String? searchQuery;

  /// 1-based page index for pagination.
  final int page;

  /// Number of records per page.
  final int pageSize;

  /// Field name used for sorting, e.g. `booking_date`, `customer_name`.
  final String sortBy;

  /// Sort direction: `true` = ascending, `false` = descending.
  final bool sortAsc;

  /// Returns a modified copy with only specified fields overridden.
  BookingFilters copyWith({
    String? status,
    DateTimeRange? dateRange,
    String? staffId,
    String? searchQuery,
    int? page,
    int? pageSize,
    String? sortBy,
    bool? sortAsc,
    bool clearStatus = false,
    bool clearDateRange = false,
    bool clearStaff = false,
    bool clearSearch = false,
  }) {
    return BookingFilters(
      status: clearStatus ? null : (status ?? this.status),
      dateRange: clearDateRange ? null : (dateRange ?? this.dateRange),
      staffId: clearStaff ? null : (staffId ?? this.staffId),
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      sortBy: sortBy ?? this.sortBy,
      sortAsc: sortAsc ?? this.sortAsc,
    );
  }

  /// Returns filters reset to page 1 — useful when filters change.
  BookingFilters resetPage() => copyWith(page: 1);

  @override
  List<Object?> get props => [
        status,
        dateRange,
        staffId,
        searchQuery,
        page,
        pageSize,
        sortBy,
        sortAsc,
      ];
}
