/// Widget for visually editing a staff member's weekly schedule.
///
/// Displays a grid with days as rows and hourly time slots as toggleable
/// cells. Changes are saved only when the user confirms with the Save button.
library;

import 'package:flutter/material.dart';

/// A weekly schedule grid editor where users can toggle working hours.
class StaffScheduleEditor extends StatefulWidget {
  /// Creates a [StaffScheduleEditor].
  ///
  /// [initialSchedule] may be null (treated as all-off).
  /// [onSave] is called with the updated schedule map on confirmation.
  /// [onCancel] dismisses the editor without persisting changes.
  const StaffScheduleEditor({
    super.key,
    required this.onSave,
    required this.onCancel,
    this.initialSchedule,
  });

  /// The existing schedule to pre-populate the grid; may be null.
  final Map<String, List<String>>? initialSchedule;

  /// Invoked with the new schedule when the user taps Save.
  final void Function(Map<String, List<String>> schedule) onSave;

  /// Invoked when the user taps Cancel.
  final VoidCallback onCancel;

  @override
  State<StaffScheduleEditor> createState() => _StaffScheduleEditorState();
}

class _StaffScheduleEditorState extends State<StaffScheduleEditor> {
  static const _days = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday',
    'Saturday', 'Sunday',
  ];

  static const _slots = [
    '08:00', '09:00', '10:00', '11:00', '12:00',
    '13:00', '14:00', '15:00', '16:00', '17:00',
    '18:00', '19:00', '20:00',
  ];

  late Map<String, Set<String>> _selected;

  @override
  void initState() {
    super.initState();
    _selected = {
      for (final day in _days)
        day: Set<String>.from(
          widget.initialSchedule?[day] ?? [],
        ),
    };
  }

  void _toggle(String day, String slot) {
    setState(() {
      if (_selected[day]!.contains(slot)) {
        _selected[day]!.remove(slot);
      } else {
        _selected[day]!.add(slot);
      }
    });
  }

  void _save() {
    final result = {
      for (final day in _days)
        if (_selected[day]!.isNotEmpty)
          day: _selected[day]!.toList()..sort(),
    };
    widget.onSave(result);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Weekly Schedule', style: theme.textTheme.titleLarge),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowHeight: 40,
            dataRowMinHeight: 36,
            dataRowMaxHeight: 36,
            columns: [
              const DataColumn(label: SizedBox(width: 90, child: Text('Day'))),
              ..._slots.map(
                (s) => DataColumn(
                  label: SizedBox(
                    width: 52,
                    child: Text(s, style: const TextStyle(fontSize: 11)),
                  ),
                ),
              ),
            ],
            rows: _days
                .map(
                  (day) => DataRow(
                    cells: [
                      DataCell(SizedBox(
                        width: 90,
                        child: Text(day.substring(0, 3),
                            style: theme.textTheme.bodyMedium),
                      )),
                      ..._slots.map(
                        (slot) => DataCell(
                          GestureDetector(
                            onTap: () => _toggle(day, slot),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: 32,
                              height: 24,
                              decoration: BoxDecoration(
                                color: _selected[day]!.contains(slot)
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _legend(theme.colorScheme.primary, 'Working'),
            const SizedBox(width: 16),
            _legend(theme.colorScheme.surfaceContainerHighest, 'Off'),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton(
              onPressed: widget.onCancel,
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 12),
            FilledButton(
              onPressed: _save,
              child: const Text('Save Schedule'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _legend(Color colour, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: colour,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      );
}
