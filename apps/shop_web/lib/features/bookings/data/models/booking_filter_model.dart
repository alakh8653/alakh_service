/// Filter model used to build API query parameters for booking list requests.
library;

import 'package:flutter/material.dart';

/// Holds all filter/pagination/sort options that the remote datasource accepts.
class BookingFilterModel {
  const BookingFilterModel({
    this.status,
    this.dateRange,
    this.staffId,
    this.searchQuery,
    this.page = 1,
    this.pageSize = 20,
    this.sortBy = 'booking_date',
    this.sortAsc = false,
  });

  /// Creates a [BookingFilterModel] with sensible defaults.
  factory BookingFilterModel.initial() => const BookingFilterModel();

  final String? status;
  final DateTimeRange? dateRange;
  final String? staffId;
  final String? searchQuery;
  final int page;
  final int pageSize;

  /// Field name to sort results by, e.g. "booking_date", "customer_name".
  final String sortBy;
  final bool sortAsc;

  /// Converts filter state to a flat map suitable for HTTP query parameters.
  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{
      'page': page.toString(),
      'page_size': pageSize.toString(),
      'sort_by': sortBy,
      'sort_asc': sortAsc.toString(),
    };

    if (status != null && status!.isNotEmpty) {
      params['status'] = status;
    }
    if (dateRange != null) {
      params['date_from'] = dateRange!.start.toIso8601String().split('T').first;
      params['date_to'] = dateRange!.end.toIso8601String().split('T').first;
    }
    if (staffId != null && staffId!.isNotEmpty) {
      params['staff_id'] = staffId;
    }
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      params['search'] = searchQuery;
    }

    return params;
  }

  /// Returns a copy of this model with the given fields replaced.
  BookingFilterModel copyWith({
    String? status,
    DateTimeRange? dateRange,
    String? staffId,
    String? searchQuery,
    int? page,
    int? pageSize,
    String? sortBy,
    bool? sortAsc,
    bool clearDateRange = false,
    bool clearStatus = false,
    bool clearStaff = false,
    bool clearSearch = false,
  }) {
    return BookingFilterModel(
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
}
