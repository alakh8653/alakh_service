/// Mixin for scroll controller management with scroll-to-top and infinite
/// scroll detection.
library;

import 'package:flutter/widgets.dart';

/// Attach to a [State] to get a managed [ScrollController] with scroll-to-top
/// and infinite-scroll callbacks.
///
/// ### Usage:
/// ```dart
/// class _ProductListState extends State<ProductList> with ScrollMixin {
///   @override
///   void onLoadMore() => controller.loadMore();
///
///   @override
///   Widget build(BuildContext context) => ListView.builder(
///     controller: scrollController,
///     ...
///   );
/// }
/// ```
mixin ScrollMixin<T extends StatefulWidget> on State<T> {
  late final ScrollController scrollController = ScrollController();

  /// Threshold in pixels from the bottom of the list at which [onLoadMore]
  /// is triggered.
  double get loadMoreThreshold => 200.0;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Override hooks
  // ---------------------------------------------------------------------------

  /// Called when the user has scrolled near the bottom of the list.
  ///
  /// Override to trigger loading the next page of data.
  void onLoadMore() {}

  /// Called when the user has scrolled to the very top.
  void onScrolledToTop() {}

  // ---------------------------------------------------------------------------
  // Public helpers
  // ---------------------------------------------------------------------------

  /// Smoothly scrolls to the top of the list.
  void scrollToTop({Duration? duration, Curve? curve}) {
    if (!scrollController.hasClients) return;
    scrollController.animateTo(
      0,
      duration: duration ?? const Duration(milliseconds: 400),
      curve: curve ?? Curves.easeOut,
    );
  }

  /// Returns `true` when the user has scrolled past [threshold] pixels from
  /// the top (useful for showing a scroll-to-top FAB).
  bool get showScrollToTop =>
      scrollController.hasClients &&
      scrollController.offset > (loadMoreThreshold * 2);

  // ---------------------------------------------------------------------------
  // Internal
  // ---------------------------------------------------------------------------

  void _onScroll() {
    if (!scrollController.hasClients) return;

    final position = scrollController.position;

    // Near bottom — trigger load-more
    if (position.pixels >= position.maxScrollExtent - loadMoreThreshold) {
      onLoadMore();
    }

    // At the very top
    if (position.pixels <= 0) {
      onScrolledToTop();
    }
  }
}
