import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A horizontally scrollable date picker showing the next [dayCount] days.
///
/// The currently selected date is highlighted. Tapping a date fires
/// [onDateSelected].
class DatePickerWidget extends StatefulWidget {
  /// Initially selected date.
  final DateTime selectedDate;

  /// Callback invoked when the user taps a date.
  final ValueChanged<DateTime> onDateSelected;

  /// Number of days to show starting from today. Defaults to 30.
  final int dayCount;

  const DatePickerWidget({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.dayCount = 30,
  });

  @override
  State<DatePickerWidget> createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  late DateTime _selected;
  late final List<DateTime> _dates;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedDate;
    final today = DateTime.now();
    _dates = List.generate(
      widget.dayCount,
      (i) => today.add(Duration(days: i)),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 80,
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _dates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final date = _dates[index];
          final isSelected = _isSameDay(date, _selected);
          return GestureDetector(
            onTap: () {
              setState(() => _selected = date);
              widget.onDateSelected(date);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 52,
              decoration: BoxDecoration(
                color: isSelected ? colorScheme.primary : colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.outlineVariant,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('MMM').format(date),
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    DateFormat('EEE').format(date),
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
