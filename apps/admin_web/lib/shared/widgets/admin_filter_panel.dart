import 'package:flutter/material.dart';

enum FilterType { select, multiSelect, dateRange, toggle }

class FilterOption<T> {
  final String label;
  final T value;

  const FilterOption({required this.label, required this.value});
}

class FilterGroup {
  final String id;
  final String label;
  final FilterType type;
  final List<FilterOption<dynamic>> options;

  const FilterGroup({
    required this.id,
    required this.label,
    required this.type,
    this.options = const [],
  });
}

class AdminFilterPanel extends StatefulWidget {
  final List<FilterGroup> filterGroups;
  final void Function(Map<String, dynamic>)? onFiltersChanged;
  final VoidCallback? onReset;

  const AdminFilterPanel({
    super.key,
    required this.filterGroups,
    this.onFiltersChanged,
    this.onReset,
  });

  @override
  State<AdminFilterPanel> createState() => _AdminFilterPanelState();
}

class _AdminFilterPanelState extends State<AdminFilterPanel> {
  bool _expanded = false;
  final Map<String, dynamic> _filters = {};

  @override
  Widget build(BuildContext context) {
    final activeCount = _filters.values
        .where((v) => v != null && v.toString().isNotEmpty && v != false)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF21262D),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF30363D)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.tune,
                  size: 16,
                  color: Color(0xFF8B949E),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Filters',
                  style: TextStyle(
                    color: Color(0xFFC9D1D9),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (activeCount > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F6FEB),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$activeCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: 8),
                Icon(
                  _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  size: 16,
                  color: const Color(0xFF8B949E),
                ),
              ],
            ),
          ),
        ),
        if (_expanded) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF161B22),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF30363D)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: widget.filterGroups.map(_buildFilterGroup).toList(),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _reset,
                      child: const Text('Reset all'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _apply,
                      child: const Text('Apply filters'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFilterGroup(FilterGroup group) {
    return SizedBox(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            group.label,
            style: const TextStyle(
              color: Color(0xFF8B949E),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          _buildFilterControl(group),
        ],
      ),
    );
  }

  Widget _buildFilterControl(FilterGroup group) {
    switch (group.type) {
      case FilterType.select:
        return _buildSelect(group);
      case FilterType.multiSelect:
        return _buildMultiSelect(group);
      case FilterType.dateRange:
        return _buildDateRange(group);
      case FilterType.toggle:
        return _buildToggle(group);
    }
  }

  Widget _buildSelect(FilterGroup group) {
    return DropdownButtonFormField<dynamic>(
      value: _filters[group.id],
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      dropdownColor: const Color(0xFF21262D),
      style: const TextStyle(color: Color(0xFFC9D1D9), fontSize: 13),
      items: [
        const DropdownMenuItem(
          value: null,
          child: Text('All', style: TextStyle(color: Color(0xFF8B949E))),
        ),
        ...group.options.map(
          (opt) => DropdownMenuItem(
            value: opt.value,
            child: Text(opt.label),
          ),
        ),
      ],
      onChanged: (value) => setState(() => _filters[group.id] = value),
    );
  }

  Widget _buildMultiSelect(FilterGroup group) {
    final selected = (_filters[group.id] as List<dynamic>?) ?? [];

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: group.options.map((opt) {
        final isSelected = selected.contains(opt.value);
        return FilterChip(
          label: Text(
            opt.label,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFFC9D1D9),
              fontSize: 12,
            ),
          ),
          selected: isSelected,
          onSelected: (val) {
            setState(() {
              final current =
                  List<dynamic>.from(_filters[group.id] as List? ?? []);
              if (val) {
                current.add(opt.value);
              } else {
                current.remove(opt.value);
              }
              _filters[group.id] = current;
            });
          },
          backgroundColor: const Color(0xFF21262D),
          selectedColor: const Color(0xFF1F6FEB),
          checkmarkColor: Colors.white,
          side: const BorderSide(color: Color(0xFF30363D)),
          padding: const EdgeInsets.symmetric(horizontal: 4),
        );
      }).toList(),
    );
  }

  Widget _buildDateRange(FilterGroup group) {
    final range = _filters[group.id] as DateTimeRange?;

    return InkWell(
      onTap: () async {
        final picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          initialDateRange: range,
          builder: (context, child) => Theme(
            data: Theme.of(context),
            child: child!,
          ),
        );
        if (picked != null) {
          setState(() => _filters[group.id] = picked);
        }
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF21262D),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFF30363D)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 14, color: Color(0xFF8B949E)),
            const SizedBox(width: 8),
            Text(
              range != null
                  ? '${_formatDate(range.start)} – ${_formatDate(range.end)}'
                  : 'Select range',
              style: TextStyle(
                color: range != null
                    ? const Color(0xFFC9D1D9)
                    : const Color(0xFF8B949E),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggle(FilterGroup group) {
    final value = _filters[group.id] as bool? ?? false;
    return Switch(
      value: value,
      onChanged: (v) => setState(() => _filters[group.id] = v),
      activeColor: const Color(0xFF1F6FEB),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  void _apply() {
    widget.onFiltersChanged?.call(Map.from(_filters));
    setState(() => _expanded = false);
  }

  void _reset() {
    setState(() => _filters.clear());
    widget.onFiltersChanged?.call({});
    widget.onReset?.call();
  }
}
