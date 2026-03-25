/// Widget that renders an interactive monthly booking calendar grid.
library;

import 'package:flutter/material.dart';
import 'package:shop_web/features/bookings/domain/entities/shop_booking.dart';

/// Displays a monthly calendar grid where each cell shows the booking count
/// for that day.  Tapping a cell invokes [onDaySelected].
class BookingCalendar extends StatelessWidget {
  const BookingCalendar({
    super.key,
    required this.month,
    required this.calendarData,
    required this.onDaySelected,
    this.selectedDay,
  });

  /// The month currently displayed.
  final DateTime month;

  /// Map of normalised day → bookings for that day.
  final Map<DateTime, List<ShopBooking>> calendarData;

  /// Callback invoked when the user taps a calendar day cell.
  final ValueChanged<DateTime> onDaySelected;

  /// Currently highlighted day (if any).
  final DateTime? selectedDay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    // Monday-based weekday offset (0 = Mon, 6 = Sun).
    final startOffset = (firstDay.weekday - 1) % 7;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildWeekdayHeader(theme),
        const SizedBox(height: 4),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            childAspectRatio: 1.1,
          ),
          itemCount: startOffset + daysInMonth,
          itemBuilder: (context, index) {
            if (index < startOffset) return const SizedBox.shrink();
            final day = index - startOffset + 1;
            final date = DateTime(month.year, month.month, day);
            return _DayCell(
              date: date,
              bookings: calendarData[date] ?? [],
              isSelected: selectedDay != null &&
                  selectedDay!.year == date.year &&
                  selectedDay!.month == date.month &&
                  selectedDay!.day == date.day,
              isToday: _isToday(date),
              onTap: () => onDaySelected(date),
            );
          },
        ),
      ],
    );
  }

  Widget _buildWeekdayHeader(ThemeData theme) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Row(
      children: weekdays
          .map(
            (d) => Expanded(
              child: Center(
                child: Text(
                  d,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}

/// Individual cell within [BookingCalendar].
class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.bookings,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
  });

  final DateTime date;
  final List<ShopBooking> bookings;
  final bool isSelected;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasBookings = bookings.isNotEmpty;

    Color bg;
    Color textColor;
    if (isSelected) {
      bg = theme.colorScheme.primary;
      textColor = theme.colorScheme.onPrimary;
    } else if (isToday) {
      bg = theme.colorScheme.primaryContainer;
      textColor = theme.colorScheme.onPrimaryContainer;
    } else {
      bg = theme.colorScheme.surface;
      textColor = theme.colorScheme.onSurface;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.dividerColor.withOpacity(0.4),
          ),
        ),
        padding: const EdgeInsets.all(6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${date.day}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: textColor,
                fontWeight:
                    isToday || isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (hasBookings) ...[
              const SizedBox(height: 2),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? textColor.withOpacity(0.25)
                      : theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${bookings.length}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? textColor
                        : theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
