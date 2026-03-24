/// Date range picker with preset chips and a custom calendar option.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Quick-select date presets for [DateRangePicker].
enum DatePreset {
  /// Only today.
  today,

  /// Only yesterday.
  yesterday,

  /// Mon–Sun of the current week.
  thisWeek,

  /// Mon–Sun of the previous week.
  lastWeek,

  /// 1st to last day of the current month.
  thisMonth,

  /// 1st to last day of the previous month.
  lastMonth,

  /// Rolling 30-day window ending today.
  last30Days,

  /// Rolling 90-day window ending today.
  last90Days,

  /// User-defined range via the date-picker dialog.
  custom,
}

/// A row of [DatePreset] quick-select chips and a "Custom" button that opens
/// the native date-range picker dialog.
///
/// Notifies the parent via [onRangeSelected] whenever the selection changes.
class DateRangePicker extends StatefulWidget {
  /// Creates a [DateRangePicker].
  const DateRangePicker({
    required this.onRangeSelected,
    this.selectedRange,
    super.key,
  });

  /// The currently active date range, or `null` if none is selected.
  final DateTimeRange? selectedRange;

  /// Called with the new [DateTimeRange] whenever the selection changes.
  final void Function(DateTimeRange range) onRangeSelected;

  @override
  State<DateRangePicker> createState() => _DateRangePickerState();
}

class _DateRangePickerState extends State<DateRangePicker> {
  DatePreset? _activePreset;
  static final _fmt = DateFormat('dd MMM yyyy');

  static const List<({DatePreset preset, String label})> _presets = [
    (preset: DatePreset.today, label: 'Today'),
    (preset: DatePreset.yesterday, label: 'Yesterday'),
    (preset: DatePreset.thisWeek, label: 'This week'),
    (preset: DatePreset.lastWeek, label: 'Last week'),
    (preset: DatePreset.thisMonth, label: 'This month'),
    (preset: DatePreset.lastMonth, label: 'Last month'),
    (preset: DatePreset.last30Days, label: 'Last 30d'),
    (preset: DatePreset.last90Days, label: 'Last 90d'),
  ];

  DateTimeRange _rangeFor(DatePreset preset) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (preset) {
      case DatePreset.today:
        return DateTimeRange(start: today, end: today);
      case DatePreset.yesterday:
        final y = today.subtract(const Duration(days: 1));
        return DateTimeRange(start: y, end: y);
      case DatePreset.thisWeek:
        final mon = today.subtract(Duration(days: today.weekday - 1));
        return DateTimeRange(start: mon, end: today);
      case DatePreset.lastWeek:
        final mon = today.subtract(Duration(days: today.weekday + 6));
        final sun = mon.add(const Duration(days: 6));
        return DateTimeRange(start: mon, end: sun);
      case DatePreset.thisMonth:
        return DateTimeRange(
          start: DateTime(today.year, today.month),
          end: today,
        );
      case DatePreset.lastMonth:
        final first = DateTime(today.year, today.month - 1);
        final last = DateTime(today.year, today.month, 0);
        return DateTimeRange(start: first, end: last);
      case DatePreset.last30Days:
        return DateTimeRange(
          start: today.subtract(const Duration(days: 29)),
          end: today,
        );
      case DatePreset.last90Days:
        return DateTimeRange(
          start: today.subtract(const Duration(days: 89)),
          end: today,
        );
      case DatePreset.custom:
        return widget.selectedRange ?? DateTimeRange(start: today, end: today);
    }
  }

  Future<void> _pickCustomRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: widget.selectedRange,
    );
    if (picked != null) {
      setState(() => _activePreset = DatePreset.custom);
      widget.onRangeSelected(picked);
    }
  }

  String get _rangeLabel {
    if (widget.selectedRange == null) return 'Select date range';
    final s = widget.selectedRange!;
    if (s.start == s.end) return _fmt.format(s.start);
    return '${_fmt.format(s.start)} – ${_fmt.format(s.end)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ..._presets.map((p) {
                final active = _activePreset == p.preset;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(p.label),
                    selected: active,
                    onSelected: (_) {
                      setState(() => _activePreset = p.preset);
                      widget.onRangeSelected(_rangeFor(p.preset));
                    },
                  ),
                );
              }),
              OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today_outlined, size: 16),
                label: const Text('Custom'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _activePreset == DatePreset.custom
                      ? theme.colorScheme.primary
                      : null,
                ),
                onPressed: _pickCustomRange,
              ),
            ],
          ),
        ),
        if (widget.selectedRange != null) ...[
          const SizedBox(height: 6),
          Text(
            _rangeLabel,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
