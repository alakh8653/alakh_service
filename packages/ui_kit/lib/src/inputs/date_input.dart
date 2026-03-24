import 'package:flutter/material.dart';

import '../theme/ui_kit_colors.dart';
import 'text_input.dart';

/// A read-only [TextInput] that opens a [showDatePicker] dialog on tap.
///
/// The selected [DateTime] is passed to [onDateSelected] and formatted with
/// [displayFormat] (default: `dd/MM/yyyy`).
class DateInput extends StatefulWidget {
  const DateInput({
    super.key,
    this.label,
    this.hint,
    this.errorText,
    this.helperText,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.onDateSelected,
    this.enabled = true,
    this.validator,
    this.displayFormat,
  });

  final String? label;
  final String? hint;
  final String? errorText;
  final String? helperText;

  /// Pre-selected date shown when the widget first builds.
  final DateTime? initialDate;

  /// Earliest selectable date. Defaults to 100 years ago.
  final DateTime? firstDate;

  /// Latest selectable date. Defaults to 10 years from now.
  final DateTime? lastDate;

  /// Called with the [DateTime] the user selects.
  final ValueChanged<DateTime>? onDateSelected;

  final bool enabled;

  /// Custom form validator receiving the current formatted string value.
  final String? Function(String?)? validator;

  /// Pattern used to format the displayed date, e.g. `'dd/MM/yyyy'`.
  final String? displayFormat;

  @override
  State<DateInput> createState() => _DateInputState();
}

class _DateInputState extends State<DateInput> {
  late final TextEditingController _controller;
  DateTime? _selected;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    if (widget.initialDate != null) {
      _selected = widget.initialDate;
      _controller.text = _format(widget.initialDate!);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _format(DateTime date) {
    final fmt = widget.displayFormat ?? 'dd/MM/yyyy';
    String result = fmt;
    result = result.replaceAll('yyyy', date.year.toString().padLeft(4, '0'));
    result = result.replaceAll('MM', date.month.toString().padLeft(2, '0'));
    result = result.replaceAll('dd', date.day.toString().padLeft(2, '0'));
    return result;
  }

  Future<void> _pickDate() async {
    if (!widget.enabled) return;

    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selected ?? now,
      firstDate: widget.firstDate ?? DateTime(now.year - 100),
      lastDate: widget.lastDate ?? DateTime(now.year + 10),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: UiKitColors.primary,
              ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        _selected = picked;
        _controller.text = _format(picked);
      });
      widget.onDateSelected?.call(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickDate,
      child: AbsorbPointer(
        child: TextInput(
          controller: _controller,
          label: widget.label,
          hint: widget.hint ?? (widget.displayFormat ?? 'dd/MM/yyyy'),
          errorText: widget.errorText,
          helperText: widget.helperText,
          enabled: widget.enabled,
          readOnly: true,
          validator: widget.validator,
          suffix: const Icon(
            Icons.calendar_today_outlined,
            size: 18,
            color: UiKitColors.grey400,
          ),
        ),
      ),
    );
  }
}
