import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../models/weight_log.dart';
import '../../utils/constants.dart';
import '../../utils/date_utils.dart';
import '../common/empty_state.dart';

/// Line chart of BMI over time, shaded by WHO category band so the user can
/// see at a glance which zone each reading fell in.
class BmiHistoryChart extends StatelessWidget {
  final List<WeightLog> logs;

  const BmiHistoryChart({super.key, required this.logs});

  static const Map<String, Color> _bandColors = {
    'underweight': Color(0xFF42A5F5),
    'normal': Color(0xFF43A047),
    'overweight': Color(0xFFFFA000),
    'obese': Color(0xFFE53935),
  };

  @override
  Widget build(BuildContext context) {
    if (logs.length < 2) {
      // No fixed height here - EmptyState sizes to its own content, which
      // avoids an overflow if its text wraps to an extra line (longer
      // locale strings, larger accessibility text scale, narrower phones).
      return const EmptyState(
        icon: Icons.monitor_heart_outlined,
        title: 'Not enough data yet',
        message: 'Log your weight at least twice to see your BMI trend.',
      );
    }

    final spots = [
      for (var i = 0; i < logs.length; i++) FlSpot(i.toDouble(), logs[i].bmi),
    ];
    final minY = 15.0;
    final maxY = (logs.map((l) => l.bmi).reduce((a, b) => a > b ? a : b) + 5).clamp(32.0, 45.0);

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          rangeAnnotations: RangeAnnotations(
            horizontalRangeAnnotations: [
              HorizontalRangeAnnotation(
                y1: minY, y2: BmiConstants.underweightMax,
                color: _bandColors['underweight']!.withValues(alpha: 0.08),
              ),
              HorizontalRangeAnnotation(
                y1: BmiConstants.underweightMax, y2: BmiConstants.normalMax,
                color: _bandColors['normal']!.withValues(alpha: 0.08),
              ),
              HorizontalRangeAnnotation(
                y1: BmiConstants.normalMax, y2: BmiConstants.overweightMax,
                color: _bandColors['overweight']!.withValues(alpha: 0.08),
              ),
              HorizontalRangeAnnotation(
                y1: BmiConstants.overweightMax, y2: maxY,
                color: _bandColors['obese']!.withValues(alpha: 0.08),
              ),
            ],
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32)),
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
              color: Theme.of(context).colorScheme.primary,
              barWidth: 3,
              dotData: const FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }
}
