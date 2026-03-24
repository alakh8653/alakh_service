import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shimmer/shimmer.dart';

enum ChartType { line, bar, pie, donut }

class ChartDataSeries {
  final String label;
  final List<double> values;
  final Color? color;

  const ChartDataSeries({
    required this.label,
    required this.values,
    this.color,
  });
}

class AdminChart extends StatelessWidget {
  final ChartType type;
  final String title;
  final List<ChartDataSeries> data;
  final bool isLoading;
  final List<String>? xLabels;

  const AdminChart({
    super.key,
    required this.type,
    required this.title,
    required this.data,
    this.isLoading = false,
    this.xLabels,
  });

  static const _defaultColors = [
    Color(0xFF1F6FEB),
    Color(0xFF3FB950),
    Color(0xFFD29922),
    Color(0xFFF85149),
    Color(0xFF8B5CF6),
    Color(0xFF06B6D4),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFC9D1D9),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: isLoading ? _buildShimmer() : _buildChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    if (data.isEmpty) {
      return const Center(
        child: Text(
          'No data available',
          style: TextStyle(color: Color(0xFF8B949E), fontSize: 13),
        ),
      );
    }

    switch (type) {
      case ChartType.line:
        return _buildLineChart();
      case ChartType.bar:
        return _buildBarChart();
      case ChartType.pie:
        return _buildPieChart(false);
      case ChartType.donut:
        return _buildPieChart(true);
    }
  }

  Widget _buildLineChart() {
    final lineBarsData = data.asMap().entries.map((entry) {
      final color = entry.value.color ?? _defaultColors[entry.key % _defaultColors.length];
      final spots = entry.value.values.asMap().entries
          .map((e) => FlSpot(e.key.toDouble(), e.value))
          .toList();

      return LineChartBarData(
        spots: spots,
        isCurved: true,
        color: color,
        barWidth: 2,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          color: color.withOpacity(0.08),
        ),
      );
    }).toList();

    return LineChart(
      LineChartData(
        lineBarsData: lineBarsData,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => const FlLine(
            color: Color(0xFF21262D),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (xLabels != null && index < xLabels!.length) {
                  return Text(
                    xLabels![index],
                    style: const TextStyle(color: Color(0xFF8B949E), fontSize: 11),
                  );
                }
                return Text(
                  '$index',
                  style: const TextStyle(color: Color(0xFF8B949E), fontSize: 11),
                );
              },
              reservedSize: 24,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: const TextStyle(color: Color(0xFF8B949E), fontSize: 11),
              ),
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _buildBarChart() {
    final barGroups = <BarChartGroupData>[];

    if (data.isNotEmpty) {
      final maxValues = data[0].values.length;
      for (var i = 0; i < maxValues; i++) {
        final rods = data.asMap().entries.map((entry) {
          final color = entry.value.color ??
              _defaultColors[entry.key % _defaultColors.length];
          return BarChartRodData(
            toY: i < entry.value.values.length ? entry.value.values[i] : 0,
            color: color,
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
          );
        }).toList();

        barGroups.add(BarChartGroupData(x: i, barRods: rods));
      }
    }

    return BarChart(
      BarChartData(
        barGroups: barGroups,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => const FlLine(
            color: Color(0xFF21262D),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (xLabels != null && index < xLabels!.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      xLabels![index],
                      style:
                          const TextStyle(color: Color(0xFF8B949E), fontSize: 11),
                    ),
                  );
                }
                return Text(
                  '$index',
                  style: const TextStyle(color: Color(0xFF8B949E), fontSize: 11),
                );
              },
              reservedSize: 28,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: const TextStyle(color: Color(0xFF8B949E), fontSize: 11),
              ),
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => const Color(0xFF21262D),
          ),
        ),
      ),
    );
  }

  Widget _buildPieChart(bool isDoughnut) {
    final sections = data.asMap().entries.map((entry) {
      final total = data.fold<double>(
        0,
        (sum, s) => sum + (s.values.isNotEmpty ? s.values[0] : 0),
      );
      final value =
          entry.value.values.isNotEmpty ? entry.value.values[0] : 0.0;
      final color = entry.value.color ??
          _defaultColors[entry.key % _defaultColors.length];
      final percentage = total > 0 ? (value / total * 100).toStringAsFixed(1) : '0';

      return PieChartSectionData(
        value: value,
        title: '$percentage%',
        color: color,
        radius: isDoughnut ? 60 : 80,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      );
    }).toList();

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: isDoughnut ? 40 : 0,
        sectionsSpace: 2,
        pieTouchData: PieTouchData(
          touchCallback: (event, response) {},
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF21262D),
      highlightColor: const Color(0xFF30363D),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
