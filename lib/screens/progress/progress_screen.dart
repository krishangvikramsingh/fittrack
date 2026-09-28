import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/stats_providers.dart';
import '../../providers/weight_providers.dart';
import '../../utils/constants.dart';
import '../../widgets/common/async_value_view.dart';
import '../../widgets/progress/bmi_history_chart.dart';
import '../../widgets/progress/chart_card.dart';
import '../../widgets/progress/weekly_calories_chart.dart';
import '../../widgets/progress/weight_trend_chart.dart';
import 'widgets/add_weight_sheet.dart';

/// The Progress tab: weight trend, weekly calories, and BMI history charts.
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weightLogsAsync = ref.watch(weightLogsProvider);
    final weeklyCaloriesAsync = ref.watch(weeklyCaloriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          AsyncValueView(
            value: weightLogsAsync,
            data: (context, logs) => ChartCard(
              title: 'Weight trend',
              action: TextButton(
                onPressed: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => const AddWeightSheet(),
                ),
                child: const Text('Log weight'),
              ),
              child: WeightTrendChart(logs: logs),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AsyncValueView(
            value: weeklyCaloriesAsync,
            data: (context, days) => ChartCard(
              title: 'Weekly calories',
              child: WeeklyCaloriesChart(days: days),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AsyncValueView(
            value: weightLogsAsync,
            data: (context, logs) => ChartCard(
              title: 'BMI history',
              child: BmiHistoryChart(logs: logs),
            ),
          ),
        ],
      ),
    );
  }
}
