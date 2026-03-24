/// Widget providing a status filter chip bar for the bookings list.
library;

import 'package:flutter/material.dart';
import 'package:shop_web/shared/shared.dart';

/// Displays a horizontal row of filter chips for each booking status.
///
/// Selecting a chip calls [onStatusChanged] with the corresponding status
/// string, or `null` when "All" is selected.
class BookingStatusFilter extends StatelessWidget {
  const BookingStatusFilter({
    super.key,
    required this.selectedStatus,
    required this.onStatusChanged,
    this.statusCounts = const {},
  });

  /// The currently active status filter, or `null` for "All".
  final String? selectedStatus;

  /// Invoked when the user taps a chip.
  final ValueChanged<String?> onStatusChanged;

  /// Optional map of status → count for rendering badge numbers on chips.
  final Map<String, int> statusCounts;

  static const _statuses = <_StatusOption>[
    _StatusOption(label: 'All', value: null, color: Colors.blueGrey),
    _StatusOption(label: 'Pending', value: 'pending', color: Colors.orange),
    _StatusOption(label: 'Confirmed', value: 'confirmed', color: Colors.blue),
    _StatusOption(label: 'Completed', value: 'completed', color: Colors.green),
    _StatusOption(label: 'Cancelled', value: 'cancelled', color: Colors.red),
    _StatusOption(label: 'No-Show', value: 'noShow', color: Colors.grey),
  ];

  @override
  Widget build(BuildContext context) {
    final chips = _statuses.map((option) {
      final count = option.value == null
          ? statusCounts.values.fold<int>(0, (a, b) => a + b)
          : (statusCounts[option.value] ?? 0);

      final label = count > 0 ? '${option.label} ($count)' : option.label;

      return FilterChipItem(
        label: label,
        value: option.value ?? 'all',
        isSelected: selectedStatus == option.value,
        color: option.color,
      );
    }).toList();

    return FilterChipBar(
      items: chips,
      onSelected: (value) =>
          onStatusChanged(value == 'all' ? null : value),
      selectedValue: selectedStatus ?? 'all',
    );
  }
}

/// Internal configuration for a single status option.
class _StatusOption {
  const _StatusOption({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String? value;
  final Color color;
}
