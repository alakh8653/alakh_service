import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/booking.dart';
import '../../domain/entities/booking_status.dart';
import '../bloc/bloc.dart';
import '../widgets/booking_list_item.dart';
import 'booking_details_page.dart';

/// Shows all bookings for the current user split across three tabs:
/// Upcoming, Past, and Cancelled.
class MyBookingsPage extends StatefulWidget {
  /// The authenticated user's identifier.
  final String userId;

  const MyBookingsPage({super.key, required this.userId});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<BookingBloc>().add(LoadUserBookings(widget.userId));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: BlocBuilder<BookingBloc, BookingState>(
        builder: (context, state) {
          if (state is SlotsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is BookingsLoaded) {
            final upcoming = state.bookings
                .where((b) =>
                    b.status == BookingStatus.pending ||
                    b.status == BookingStatus.confirmed ||
                    b.status == BookingStatus.inProgress)
                .toList();
            final past = state.bookings
                .where((b) =>
                    b.status == BookingStatus.completed ||
                    b.status == BookingStatus.noShow)
                .toList();
            final cancelled = state.bookings
                .where((b) => b.status == BookingStatus.cancelled)
                .toList();

            return TabBarView(
              controller: _tabController,
              children: [
                _BookingList(bookings: upcoming, emptyMessage: 'No upcoming bookings.'),
                _BookingList(bookings: past, emptyMessage: 'No past bookings.'),
                _BookingList(bookings: cancelled, emptyMessage: 'No cancelled bookings.'),
              ],
            );
          }
          if (state is BookingError) {
            return _ErrorView(
              message: state.message,
              onRetry: () => context
                  .read<BookingBloc>()
                  .add(LoadUserBookings(widget.userId)),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _BookingList extends StatelessWidget {
  final List<Booking> bookings;
  final String emptyMessage;

  const _BookingList({required this.bookings, required this.emptyMessage});

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_busy_rounded,
                size: 56,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(emptyMessage),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () async {
        // Refresh handled by parent BLoC.
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return BookingListItem(
            booking: booking,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<BookingBloc>(),
                  child: BookingDetailsPage(bookingId: booking.id),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
