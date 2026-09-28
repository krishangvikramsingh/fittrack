import 'package:flutter/material.dart' hide StepState;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/stats.dart';
import '../../models/step_log.dart';
import '../../providers/step_providers.dart';
import '../../providers/streak_providers.dart';
import '../../utils/constants.dart';
import '../common/stat_card.dart';

/// The 2x2 grid of quick stats on the dashboard: today's calories, live
/// steps, current streak and today's workout count.
class StatsGrid extends ConsumerWidget {
  final DayStats todayStats;
  final VoidCallback onStreakTap;

  const StatsGrid({super.key, required this.todayStats, required this.onStreakTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stepState = ref.watch(stepCountProvider);
    final streak = ref.watch(streakProvider).valueOrNull;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.sm,
      childAspectRatio: 1.5,
      children: [
        StatCard(
          icon: Icons.local_fire_department,
          label: 'Calories today',
          value: '${todayStats.caloriesBurned.round()} kcal',
        ),
        _buildStepCard(context, stepState),
        StatCard(
          icon: Icons.whatshot,
          iconColor: Colors.orange,
          label: 'Day streak',
          value: '${streak?.currentStreak ?? 0}',
          onTap: onStreakTap,
        ),
        StatCard(
          icon: Icons.fitness_center,
          label: 'Workouts today',
          value: '${todayStats.workoutCount}',
        ),
      ],
    );
  }

  Widget _buildStepCard(BuildContext context, AsyncValue<StepState> stepState) {
    return stepState.when(
      data: (state) => switch (state) {
        StepCountAvailable(:final steps) =>
          StatCard(icon: Icons.directions_walk, label: 'Steps today', value: '$steps'),
        StepCountPermissionDenied() =>
          const StatCard(icon: Icons.directions_walk, label: 'Steps today', value: 'No access'),
        StepCountUnavailable() =>
          const StatCard(icon: Icons.directions_walk, label: 'Steps today', value: 'N/A'),
      },
      loading: () => const StatCard(icon: Icons.directions_walk, label: 'Steps today', value: '…'),
      error: (_, __) => const StatCard(icon: Icons.directions_walk, label: 'Steps today', value: 'N/A'),
    );
  }
}
