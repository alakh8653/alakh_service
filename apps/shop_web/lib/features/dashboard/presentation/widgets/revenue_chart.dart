import 'package:flutter/material.dart';
import 'package:shop_web/features/dashboard/domain/entities/revenue_data.dart';
import 'package:shop_web/shared/shared.dart';

/// Revenue chart card displayed on the Dashboard.
///
/// Shows revenue and expenses as separate lines. Provides period toggle
/// buttons (7 d / 30 d / 90 d / 1 y) that fire [onPeriodChanged] with the
/// corresponding [DateTimeRange] so the parent can trigger a new BLoC event.
class RevenueChart extends StatefulWidget {
  final List<RevenueData> data;
  final void Function(DateTimeRange range) onPeriodChanged;

  const RevenueChart({
    super.key,
    required this.data,
    required this.onPeriodChanged,
  });

  @override
  State<RevenueChart> createState() => _RevenueChartState();
}

class _RevenueChartState extends State<RevenueChart> {
  int _selectedPeriodDays = 30;

  static const _periods = [
    _Period(label: '7 d', days: 7),
    _Period(label: '30 d', days: 30),
    _Period(label: '90 d', days: 90),
    _Period(label: '1 y', days: 365),
  ];

  void _selectPeriod(int days) {
    setState(() => _selectedPeriodDays = days);
    final end = DateTime.now();
    final start = end.subtract(Duration(days: days));
    widget.onPeriodChanged(DateTimeRange(start: start, end: end));
  }

  @override
  Widget build(BuildContext context) {
    final revenuePoints = widget.data
        .map((d) => ShopChartData(label: d.period, value: d.revenue))
        .toList();
    final expensePoints = widget.data
        .map((d) => ShopChartData(label: d.period, value: d.expenses))
        .toList();

    return ContentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Revenue Overview',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              ..._periods.map((p) => Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: ChoiceChip(
                      label: Text(p.label),
                      selected: _selectedPeriodDays == p.days,
                      onSelected: (_) => _selectPeriod(p.days),
                    ),
                  )),
            ],
          ),
          const SizedBox(height: 16),
          if (widget.data.isEmpty)
            const EmptyTableState(message: 'No revenue data available.')
          else
            ShopChart(
              type: ShopChartType.line,
              dataSeries: [
                ShopChartSeries(
                  label: 'Revenue',
                  color: Colors.green,
                  data: revenuePoints,
                ),
                ShopChartSeries(
                  label: 'Expenses',
                  color: Colors.red,
                  data: expensePoints,
                ),
              ],
              height: 260,
            ),
        ],
      ),
    );
  }
}

class _Period {
  final String label;
  final int days;
  const _Period({required this.label, required this.days});
}
