import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../models/stats.dart';
import '../../utils/date_utils.dart';
import '../../utils/theme.dart';
import '../common/empty_state.dart';

/// Bar chart of calories burned per day over the last 7 days.
class WeeklyCaloriesChart extends StatelessWidget {
  final List<DailyTotal> days;

  const WeeklyCaloriesChart({super.key, required this.days});

  @override
  Widget build(BuildContext context) {
    if (days.every((d) => d.calories == 0)) {
      // No fixed height here - EmptyState sizes to its own content, which
      // avoids an overflow if its text wraps to an extra line (longer
      // locale strings, larger accessibility text scale, narrower phones).
      return const EmptyState(
        icon: Icons.bar_chart,
        title: 'No calories logged this week',
        message: 'Log a workout to see your weekly totals here.',
      );
    }

    final maxY = days.map((d) => d.calories).reduce((a, b) => a > b ? a : b);
    final color = AppTheme.chartPalette[1];

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          maxY: maxY * 1.2,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 36)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.round();
                  if (index < 0 || index >= days.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      AppDateUtils.weekdayShortFormat.format(days[index].date),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < days.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: days[i].calories,
                    color: color,
                    width: 18,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
