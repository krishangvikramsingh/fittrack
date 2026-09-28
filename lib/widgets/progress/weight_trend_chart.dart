import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../models/weight_log.dart';
import '../../utils/date_utils.dart';
import '../../utils/theme.dart';
import '../common/empty_state.dart';

/// Line chart of every logged weight entry over time.
class WeightTrendChart extends StatelessWidget {
  final List<WeightLog> logs;

  const WeightTrendChart({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    if (logs.length < 2) {
      // No fixed height here - EmptyState sizes to its own content, which
      // avoids an overflow if its text wraps to an extra line (longer
      // locale strings, larger accessibility text scale, narrower phones).
      return const EmptyState(
        icon: Icons.monitor_weight_outlined,
        title: 'Not enough data yet',
        message: 'Log your weight at least twice to see a trend.',
      );
    }

    final spots = [
      for (var i = 0; i < logs.length; i++) FlSpot(i.toDouble(), logs[i].weightKg),
    ];
    final color = AppTheme.chartPalette[0];

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 36, interval: _yInterval(spots)),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 26,
                interval: (logs.length / 4).clamp(1, logs.length).roundToDouble(),
                getTitlesWidget: (value, meta) {
                  final index = value.round();
                  if (index < 0 || index >= logs.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      AppDateUtils.dayMonthFormat.format(logs[index].loggedAt),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: color,
              barWidth: 3,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: color.withValues(alpha: 0.12)),
            ),
          ],
        ),
      ),
    );
  }

  double _yInterval(List<FlSpot> spots) {
    final values = spots.map((s) => s.y);
    final range = values.reduce((a, b) => a > b ? a : b) - values.reduce((a, b) => a < b ? a : b);
    if (range <= 0) return 1;
    return (range / 4).clamp(1, double.infinity);
  }
}
