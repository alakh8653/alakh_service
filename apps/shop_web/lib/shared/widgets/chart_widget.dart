/// Chart widget wrapping fl_chart for bar, line, and pie charts.
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Supported chart types rendered by [ShopChart].
enum ShopChartType {
  /// Vertical bar / column chart.
  bar,

  /// Connected line / area chart.
  line,

  /// Segmented pie / donut chart.
  pie,
}

/// Data point for [ShopChart].
class ShopChartData {
  /// Creates a [ShopChartData] entry.
  const ShopChartData({
    required this.label,
    required this.value,
    this.color,
  });

  /// X-axis label or slice label.
  final String label;

  /// Numeric value for this data point.
  final double value;

  /// Optional override colour; a default palette is used when `null`.
  final Color? color;
}

/// Renders a bar, line, or pie chart from a list of [ShopChartData] entries.
///
/// Requires the `fl_chart` package.
class ShopChart extends StatefulWidget {
  /// Creates a [ShopChart].
  const ShopChart({
    required this.type,
    required this.data,
    this.title,
    this.height,
    super.key,
  });

  /// The visual chart style to render.
  final ShopChartType type;

  /// Data series to display.
  final List<ShopChartData> data;

  /// Optional chart title displayed above the chart area.
  final String? title;

  /// Chart canvas height in logical pixels.  Defaults to 260.
  final double? height;

  @override
  State<ShopChart> createState() => _ShopChartState();
}

class _ShopChartState extends State<ShopChart> {
  int _touchedIndex = -1;

  static const List<Color> _defaultPalette = [
    Color(0xFF5C6BC0),
    Color(0xFF26A69A),
    Color(0xFFEF5350),
    Color(0xFFFFCA28),
    Color(0xFF66BB6A),
    Color(0xFF29B6F6),
    Color(0xFFFF7043),
    Color(0xFFAB47BC),
  ];

  Color _colorFor(int index) =>
      widget.data[index].color ?? _defaultPalette[index % _defaultPalette.length];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chartHeight = widget.height ?? 260.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.title != null) ...[
          Text(
            widget.title!,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
        ],
        SizedBox(
          height: chartHeight,
          child: _buildChart(theme),
        ),
        if (widget.type == ShopChartType.pie) ...[
          const SizedBox(height: 12),
          _Legend(data: widget.data, colorFor: _colorFor),
        ],
      ],
    );
  }

  Widget _buildChart(ThemeData theme) {
    switch (widget.type) {
      case ShopChartType.bar:
        return _buildBarChart(theme);
      case ShopChartType.line:
        return _buildLineChart(theme);
      case ShopChartType.pie:
        return _buildPieChart();
    }
  }

  // ---------------------------------------------------------------------------
  // Bar chart
  // ---------------------------------------------------------------------------

  BarChart _buildBarChart(ThemeData theme) {
    return BarChart(
      BarChartData(
        barGroups: List.generate(widget.data.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: widget.data[i].value,
                color: _colorFor(i),
                width: 20,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= widget.data.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    widget.data[idx].label,
                    style: theme.textTheme.labelSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
              reservedSize: 36,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text(
                meta.formattedValue,
                style: theme.textTheme.labelSmall,
              ),
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(drawVerticalLine: false),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
              '${widget.data[group.x].label}\n${rod.toY.toStringAsFixed(1)}',
              const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Line chart
  // ---------------------------------------------------------------------------

  LineChart _buildLineChart(ThemeData theme) {
    final spots = List.generate(
      widget.data.length,
      (i) => FlSpot(i.toDouble(), widget.data[i].value),
    );

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: _colorFor(0),
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: _colorFor(0).withOpacity(0.15),
            ),
          ),
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= widget.data.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(widget.data[idx].label, style: theme.textTheme.labelSmall),
                );
              },
              reservedSize: 36,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text(
                meta.formattedValue,
                style: theme.textTheme.labelSmall,
              ),
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: theme.dividerColor),
            left: BorderSide(color: theme.dividerColor),
          ),
        ),
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: theme.dividerColor,
            strokeWidth: 0.5,
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) => spots
                .map((s) => LineTooltipItem(
                      s.y.toStringAsFixed(1),
                      const TextStyle(color: Colors.white, fontSize: 12),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Pie chart
  // ---------------------------------------------------------------------------

  PieChart _buildPieChart() {
    return PieChart(
      PieChartData(
        sections: List.generate(widget.data.length, (i) {
          final isTouched = i == _touchedIndex;
          return PieChartSectionData(
            value: widget.data[i].value,
            color: _colorFor(i),
            radius: isTouched ? 80 : 70,
            title: isTouched ? '${widget.data[i].value.toStringAsFixed(1)}' : '',
            titleStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          );
        }),
        pieTouchData: PieTouchData(
          touchCallback: (event, response) {
            setState(() {
              _touchedIndex =
                  (event.isInterestedForInteractions && response?.touchedSection != null)
                      ? response!.touchedSection!.touchedSectionIndex
                      : -1;
            });
          },
        ),
        centerSpaceRadius: 40,
        sectionsSpace: 2,
      ),
    );
  }
}

/// Horizontal legend strip for pie chart.
class _Legend extends StatelessWidget {
  const _Legend({required this.data, required this.colorFor});

  final List<ShopChartData> data;
  final Color Function(int) colorFor;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: List.generate(data.length, (i) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: colorFor(i),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 4),
            Text(data[i].label, style: const TextStyle(fontSize: 12)),
          ],
        );
      }),
    );
  }
}
