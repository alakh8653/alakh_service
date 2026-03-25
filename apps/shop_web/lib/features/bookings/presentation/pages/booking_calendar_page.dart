/// Calendar view page for the bookings feature.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_web/features/bookings/domain/entities/booking_filters.dart';
import 'package:shop_web/features/bookings/domain/entities/shop_booking.dart';
import 'package:shop_web/features/bookings/presentation/bloc/shop_bookings_bloc.dart';
import 'package:shop_web/features/bookings/presentation/bloc/shop_bookings_event.dart';
import 'package:shop_web/features/bookings/presentation/bloc/shop_bookings_state.dart';
import 'package:shop_web/features/bookings/presentation/pages/booking_detail_modal.dart';
import 'package:shop_web/features/bookings/presentation/widgets/booking_calendar.dart';
import 'package:shop_web/shared/shared.dart';

/// Page that presents the [BookingCalendar] widget with month navigation
/// and a side panel listing the bookings for the currently selected day.
class BookingCalendarPage extends StatefulWidget {
  const BookingCalendarPage({super.key});

  @override
  State<BookingCalendarPage> createState() => _BookingCalendarPageState();
}

class _BookingCalendarPageState extends State<BookingCalendarPage> {
  late DateTime _displayedMonth;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _displayedMonth = DateTime(now.year, now.month);
    _loadCalendar();
  }

  void _loadCalendar() {
    context
        .read<ShopBookingsBloc>()
        .add(LoadBookingCalendar(_displayedMonth));
  }

  void _previousMonth() {
    setState(() {
      _displayedMonth =
          DateTime(_displayedMonth.year, _displayedMonth.month - 1);
      _selectedDay = null;
    });
    _loadCalendar();
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth =
          DateTime(_displayedMonth.year, _displayedMonth.month + 1);
      _selectedDay = null;
    });
    _loadCalendar();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShopBookingsBloc, ShopBookingsState>(
      builder: (context, state) {
        final loaded = state is ShopBookingsLoaded ? state : null;
        final calendarData =
            loaded?.calendarData ?? <DateTime, List<ShopBooking>>{};
        final selectedBookings =
            _selectedDay != null ? (calendarData[_selectedDay] ?? []) : <ShopBooking>[];

        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PageHeader(
                  title: 'Booking Calendar',
                  breadcrumbs: const [
                    BreadcrumbItem(label: 'Home', routeName: '/'),
                    BreadcrumbItem(
                        label: 'Bookings', routeName: '/bookings'),
                    BreadcrumbItem(label: 'Calendar'),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: ContentCard(
                          child: Column(
                            children: [
                              _buildMonthNavigation(context),
                              const SizedBox(height: 12),
                              if (state is ShopBookingsLoading)
                                const Expanded(
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              else
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: BookingCalendar(
                                      month: _displayedMonth,
                                      calendarData: calendarData,
                                      selectedDay: _selectedDay,
                                      onDaySelected: (day) =>
                                          setState(() => _selectedDay = day),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 320,
                        child: ContentCard(
                          child: _buildDayPanel(context, selectedBookings),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMonthNavigation(BuildContext context) {
    final theme = Theme.of(context);
    final monthLabel =
        '${_monthName(_displayedMonth.month)} ${_displayedMonth.year}';
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          tooltip: 'Previous month',
          onPressed: _previousMonth,
        ),
        Expanded(
          child: Text(
            monthLabel,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          tooltip: 'Next month',
          onPressed: _nextMonth,
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: () {
            final now = DateTime.now();
            setState(() {
              _displayedMonth = DateTime(now.year, now.month);
              _selectedDay = null;
            });
            _loadCalendar();
          },
          child: const Text('Today'),
        ),
      ],
    );
  }

  Widget _buildDayPanel(BuildContext context, List<ShopBooking> bookings) {
    if (_selectedDay == null) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.touch_app, size: 40, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'Select a day to\nsee bookings',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    final dayLabel =
        '${_selectedDay!.day} ${_monthName(_selectedDay!.month)} ${_selectedDay!.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          dayLabel,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          '${bookings.length} booking${bookings.length == 1 ? '' : 's'}',
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const Divider(height: 16),
        if (bookings.isEmpty)
          const Expanded(
            child: Center(
              child: Text('No bookings on this day.'),
            ),
          )
        else
          Expanded(
            child: ListView.separated(
              itemCount: bookings.length,
              separatorBuilder: (_, __) => const Divider(height: 8),
              itemBuilder: (context, index) =>
                  _BookingDayTile(booking: bookings[index]),
            ),
          ),
      ],
    );
  }

  String _monthName(int month) {
    const names = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return names[month - 1];
  }
}

/// Compact list tile shown in the day detail panel.
class _BookingDayTile extends StatelessWidget {
  const _BookingDayTile({required this.booking});

  final ShopBooking booking;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => BookingDetailModal.show(context, booking),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: _statusColor(booking.status),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.customerName,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${booking.timeSlot} · ${booking.serviceName}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
