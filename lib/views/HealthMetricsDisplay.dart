import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class HealthMetricsDisplay extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> data;
  final Color color;
  final bool showDots;

  const HealthMetricsDisplay({
    Key? key,
    required this.title,
    required this.data,
    required this.color,
    this.showDots = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sort data by date to ensure proper chronological ordering
    final sortedData = List<Map<String, dynamic>>.from(
      data,
    )..sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));

    if (sortedData.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(child: Text('No $title data available')),
        ),
      );
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(height: 200, child: _buildChart(sortedData, context)),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(
    List<Map<String, dynamic>> chartData,
    BuildContext context,
  ) {
    // Ensure we have data to display
    if (chartData.isEmpty ||
        chartData.every((element) => element['value'] == 0)) {
      return Center(child: Text('No data available for the selected period'));
    }

    // Calculate min and max values for better axis visualization
    final values = chartData.map((e) => e['value'] as num).toList();
    final minY = values.reduce((a, b) => a < b ? a : b).toDouble();
    final maxY = values.reduce((a, b) => a > b ? a : b).toDouble();

    // Add a small buffer to max and min for better visualization
    final buffer = (maxY - minY) * 0.1;
    final effectiveMinY = (minY - buffer).clamp(0, double.infinity);
    final effectiveMaxY = maxY + buffer;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          getDrawingHorizontalLine:
              (value) =>
                  FlLine(color: Colors.grey.withOpacity(0.3), strokeWidth: 1),
          getDrawingVerticalLine:
              (value) =>
                  FlLine(color: Colors.grey.withOpacity(0.3), strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget:
                  (value, meta) => _bottomTitleWidgets(value, meta, chartData),
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) => _leftTitleWidgets(value, meta),
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.withOpacity(0.5)),
        ),
        minX: 0,
        maxX: chartData.length - 1.0,
        minY: effectiveMinY.toDouble(),
        maxY: effectiveMaxY,
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(chartData.length, (i) {
              return FlSpot(i.toDouble(), chartData[i]['value'].toDouble());
            }),
            isCurved: true,
            color: color,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: showDots,
              getDotPainter:
                  (spot, percent, barData, index) => FlDotCirclePainter(
                    radius: 4,
                    color: color,
                    strokeWidth: 1,
                    strokeColor: Colors.white,
                  ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: color.withOpacity(0.2),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            // tooltipBgColor: Theme.of(context).cardColor,
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((spot) {
                final date = chartData[spot.x.toInt()]['date'] as DateTime;
                final value = spot.y;

                return LineTooltipItem(
                  '${DateFormat('MMM d').format(date)}: $value',
                  TextStyle(color: color, fontWeight: FontWeight.bold),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _bottomTitleWidgets(
    double value,
    TitleMeta meta,
    List<Map<String, dynamic>> data,
  ) {
    final int index = value.toInt();
    if (index < 0 || index >= data.length) {
      return const SizedBox.shrink();
    }

    final date = data[index]['date'] as DateTime;
    return SideTitleWidget(
      space: 8,
      meta: meta,
      child: Text(
        DateFormat('d').format(date),
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _leftTitleWidgets(double value, TitleMeta meta) {
    return SideTitleWidget(
      meta: meta,
      space: 8,
      child: Text(
        value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1),
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
