import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/time_slot.dart';

/// A 3-column grid of time slot buttons.
///
/// Unavailable slots are rendered in a disabled state. Tapping an available
/// slot fires [onSlotSelected] with the chosen [TimeSlot].
class TimeSlotGrid extends StatelessWidget {
  /// The slots to display.
  final List<TimeSlot> slots;

  /// The currently selected slot, if any.
  final TimeSlot? selectedSlot;

  /// Callback invoked when the user selects an available slot.
  final ValueChanged<TimeSlot> onSlotSelected;

  const TimeSlotGrid({
    super.key,
    required this.slots,
    required this.onSlotSelected,
    this.selectedSlot,
  });

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty) {
      return const Center(
        child: Text('No time slots available for this date.'),
      );
    }
    final colorScheme = Theme.of(context).colorScheme;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.2,
      ),
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final slot = slots[index];
        final isSelected = selectedSlot?.id == slot.id;
        return _SlotButton(
          slot: slot,
          isSelected: isSelected,
          colorScheme: colorScheme,
          onTap: slot.isAvailable ? () => onSlotSelected(slot) : null,
        );
      },
    );
  }
}

class _SlotButton extends StatelessWidget {
  final TimeSlot slot;
  final bool isSelected;
  final ColorScheme colorScheme;
  final VoidCallback? onTap;

  const _SlotButton({
    required this.slot,
    required this.isSelected,
    required this.colorScheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color background;
    Color foreground;
    Color border;

    if (!slot.isAvailable) {
      background = colorScheme.surfaceContainerHighest;
      foreground = colorScheme.onSurface.withOpacity(0.38);
      border = Colors.transparent;
    } else if (isSelected) {
      background = colorScheme.primary;
      foreground = colorScheme.onPrimary;
      border = colorScheme.primary;
    } else {
      background = colorScheme.surface;
      foreground = colorScheme.onSurface;
      border = colorScheme.outline;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: border),
        ),
        alignment: Alignment.center,
        child: Text(
          DateFormat('h:mm a').format(slot.startTime),
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: foreground,
          ),
        ),
      ),
    );
  }
}
