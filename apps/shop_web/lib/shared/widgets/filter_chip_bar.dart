/// Horizontally scrollable filter chip bar for category / tag filtering.
library;

import 'package:flutter/material.dart';

/// A single selectable chip displayed in [FilterChipBar].
class FilterChipItem {
  /// Creates a [FilterChipItem].
  const FilterChipItem({
    required this.id,
    required this.label,
    this.count,
  });

  /// Unique identifier used to track selection.
  final String id;

  /// Display label shown inside the chip.
  final String label;

  /// Optional count badge appended to the label.
  final int? count;
}

/// A horizontally scrollable row of [ChoiceChip]s for filtering data.
///
/// Only one chip can be selected at a time.  Pass the currently active
/// chip's [FilterChipItem.id] as [selectedId] to highlight it.
///
/// A count badge is shown next to each label when [FilterChipItem.count] is
/// provided.
class FilterChipBar extends StatelessWidget {
  /// Creates a [FilterChipBar].
  const FilterChipBar({
    required this.items,
    required this.onSelected,
    this.selectedId,
    super.key,
  });

  /// All available filter options.
  final List<FilterChipItem> items;

  /// Called with the [FilterChipItem.id] of the tapped chip.
  final void Function(String id) onSelected;

  /// The [FilterChipItem.id] of the currently active filter, or `null` for
  /// no selection.
  final String? selectedId;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: items.map((item) {
          final isSelected = item.id == selectedId;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              selected: isSelected,
              label: _ChipLabel(item: item),
              onSelected: (_) => onSelected(item.id),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ChipLabel extends StatelessWidget {
  const _ChipLabel({required this.item});

  final FilterChipItem item;

  @override
  Widget build(BuildContext context) {
    if (item.count == null) return Text(item.label);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(item.label),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '${item.count}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}
