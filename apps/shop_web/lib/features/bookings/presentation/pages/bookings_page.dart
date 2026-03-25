/// Full bookings list page with filtering, search, pagination, and export.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_web/features/bookings/domain/entities/booking_filters.dart';
import 'package:shop_web/features/bookings/presentation/bloc/shop_bookings_bloc.dart';
import 'package:shop_web/features/bookings/presentation/bloc/shop_bookings_event.dart';
import 'package:shop_web/features/bookings/presentation/bloc/shop_bookings_state.dart';
import 'package:shop_web/features/bookings/presentation/widgets/booking_status_filter.dart';
import 'package:shop_web/features/bookings/presentation/widgets/bookings_table.dart';
import 'package:shop_web/shared/shared.dart';

/// Primary page for browsing and managing bookings.
///
/// Provides a [PageHeader], status filter chips, search, date-range picker,
/// export button, and the [BookingsTable] with pagination controls.
class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  @override
  void initState() {
    super.initState();
    context
        .read<ShopBookingsBloc>()
        .add(LoadBookings(BookingFilters.initial()));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShopBookingsBloc, ShopBookingsState>(
      builder: (context, state) {
        final isLoaded = state is ShopBookingsLoaded;
        final isLoading = state is ShopBookingsLoading;
        final isError = state is ShopBookingsError;
        final loaded = isLoaded ? state : null;

        final filters =
            loaded?.currentFilters ?? BookingFilters.initial();

        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PageHeader(
                  title: 'Bookings',
                  subtitle: isLoaded
                      ? '${loaded!.totalCount} total bookings'
                      : null,
                  breadcrumbs: const [
                    BreadcrumbItem(label: 'Home', routeName: '/'),
                    BreadcrumbItem(label: 'Bookings'),
                  ],
                  actions: [
                    ExportButton(
                      onExport: (format) =>
                          _handleExport(context, format, filters),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildStatCards(loaded),
                const SizedBox(height: 16),
                BookingStatusFilter(
                  selectedStatus: filters.status,
                  onStatusChanged: (status) => _applyFilter(
                    context,
                    filters.copyWith(
                      clearStatus: status == null,
                      status: status,
                    ),
                  ),
                  statusCounts: _buildStatusCounts(loaded?.bookings ?? []),
                ),
                const SizedBox(height: 12),
                _buildToolbar(context, filters),
                const SizedBox(height: 16),
                Expanded(
                  child: ContentCard(
                    child: _buildBody(context, state, loaded, isLoading, isError),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCards(ShopBookingsLoaded? loaded) {
    final bookings = loaded?.bookings ?? [];
    final confirmed = bookings.where((b) => b.isConfirmed).length;
    final pending = bookings.where((b) => b.isPending).length;
    final completed = bookings.where((b) => b.isCompleted).length;
    final cancelled = bookings.where((b) => b.isCancelled).length;

    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: 'Confirmed',
            value: confirmed.toString(),
            icon: Icons.check_circle_outline,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            title: 'Pending',
            value: pending.toString(),
            icon: Icons.hourglass_empty,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            title: 'Completed',
            value: completed.toString(),
            icon: Icons.task_alt,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            title: 'Cancelled',
            value: cancelled.toString(),
            icon: Icons.cancel_outlined,
            color: Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildToolbar(BuildContext context, BookingFilters filters) {
    final bloc = context.read<ShopBookingsBloc>();
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: SearchField(
            initialValue: filters.searchQuery ?? '',
            hint: 'Search by customer or service…',
            onChanged: (q) => bloc.add(SearchBookings(q)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: DateRangePicker(
            initialRange: filters.dateRange,
            onRangeSelected: (range) => _applyFilter(
              context,
              filters.copyWith(
                clearDateRange: range == null,
                dateRange: range,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(
    BuildContext context,
    ShopBookingsState state,
    ShopBookingsLoaded? loaded,
    bool isLoading,
    bool isError,
  ) {
    if (isLoading) {
      return const LoadingTable(columnCount: 8);
    }
    if (isError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text((state as ShopBookingsError).message),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context
                  .read<ShopBookingsBloc>()
                  .add(LoadBookings(BookingFilters.initial())),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (loaded == null || loaded.bookings.isEmpty) {
      return const EmptyTableState(
        message: 'No bookings found',
        icon: Icons.event_busy,
      );
    }

    final actionId = loaded is BookingActionInProgress
        ? (loaded as BookingActionInProgress).actionBookingId
        : null;

    return BookingsTable(
      bookings: loaded.bookings,
      totalCount: loaded.totalCount,
      currentPage: loaded.currentFilters.page,
      pageSize: loaded.currentFilters.pageSize,
      sortBy: loaded.currentFilters.sortBy,
      sortAsc: loaded.currentFilters.sortAsc,
      actionBookingId: actionId,
      onPageChanged: (page) =>
          context.read<ShopBookingsBloc>().add(ChangePage(page)),
    );
  }

  void _applyFilter(BuildContext context, BookingFilters filters) {
    context.read<ShopBookingsBloc>().add(FilterBookings(filters));
  }

  Map<String, int> _buildStatusCounts(
    List bookings,
  ) {
    final counts = <String, int>{};
    for (final b in bookings) {
      counts[b.status] = (counts[b.status] ?? 0) + 1;
    }
    return counts;
  }

  void _handleExport(
    BuildContext context,
    String format,
    BookingFilters filters,
  ) {
    // Export handled by a dedicated export service; stub for now.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exporting bookings as $format…')),
    );
  }
}
