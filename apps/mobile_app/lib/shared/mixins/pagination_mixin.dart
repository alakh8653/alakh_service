/// Mixin for paginated list loading with load-more and refresh support.
library;

import 'package:flutter/foundation.dart';

/// A page descriptor returned by a paginated data source.
class PageResult<T> {
  const PageResult({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    this.totalCount,
  });

  /// The items on this page.
  final List<T> items;

  /// The 1-based page number of these results.
  final int currentPage;

  /// Total number of pages available.
  final int totalPages;

  /// Total number of items across all pages (may be null if unknown).
  final int? totalCount;

  /// Returns `true` when there are more pages to load.
  bool get hasNextPage => currentPage < totalPages;
}

/// Attach to a [ChangeNotifier] to add paginated list management.
///
/// ### Usage:
/// ```dart
/// class ProductListController extends ChangeNotifier with PaginationMixin<Product> {
///   @override
///   Future<PageResult<Product>> fetchPage(int page) async {
///     return await _repo.getProducts(page: page);
///   }
/// }
/// ```
mixin PaginationMixin<T> on ChangeNotifier {
  final List<T> _items = [];
  int _currentPage = 0;
  int _totalPages = 1;
  bool _isLoadingInitial = false;
  bool _isLoadingMore = false;
  String? _errorMessage;

  /// All loaded items so far.
  List<T> get items => List.unmodifiable(_items);

  /// Returns `true` while the first page is being fetched.
  bool get isLoadingInitial => _isLoadingInitial;

  /// Returns `true` while additional pages are being fetched.
  bool get isLoadingMore => _isLoadingMore;

  /// Returns `true` when no items have been loaded yet and no load is active.
  bool get isEmpty => !_isLoadingInitial && _items.isEmpty && !hasError;

  /// Whether there are more pages to fetch.
  bool get hasMore => _currentPage < _totalPages;

  /// The most recent error, or `null`.
  String? get errorMessage => _errorMessage;

  /// Returns `true` when there is an active error.
  bool get hasError => _errorMessage != null;

  // ---------------------------------------------------------------------------
  // Abstract interface
  // ---------------------------------------------------------------------------

  /// Subclasses must implement this method to load the given [page] number.
  Future<PageResult<T>> fetchPage(int page);

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Clears existing items and loads the first page.
  Future<void> refresh() async {
    _items.clear();
    _currentPage = 0;
    _totalPages = 1;
    _errorMessage = null;
    await _loadPage(isInitial: true);
  }

  /// Loads the next page if more data is available and no load is in progress.
  Future<void> loadMore() async {
    if (!hasMore || _isLoadingMore || _isLoadingInitial) return;
    await _loadPage(isInitial: false);
  }

  // ---------------------------------------------------------------------------
  // Internal
  // ---------------------------------------------------------------------------

  Future<void> _loadPage({required bool isInitial}) async {
    if (isInitial) {
      _isLoadingInitial = true;
    } else {
      _isLoadingMore = true;
    }
    _errorMessage = null;
    notifyListeners();

    try {
      final page = _currentPage + 1;
      final result = await fetchPage(page);
      _items.addAll(result.items);
      _currentPage = result.currentPage;
      _totalPages = result.totalPages;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingInitial = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }
}
