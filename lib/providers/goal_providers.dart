import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/goals.dart';
import '../models/step_log.dart';
import '../repositories/goal_repository.dart';
import '../utils/date_utils.dart';
import 'core_providers.dart';
import 'stats_providers.dart';
import 'step_providers.dart';
import 'workout_providers.dart';

/// Holds the user's daily/weekly targets, loaded once and updated from the
/// Goals screen.
class GoalsNotifier extends StateNotifier<AsyncValue<Goals>> {
  final GoalRepository _repo;

  GoalsNotifier(this._repo) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.getGoals());
  }

  Future<void> updateGoals(Goals goals) async {
    await _repo.saveGoals(goals);
    state = AsyncValue.data(goals);
  }
}

final goalsProvider = StateNotifierProvider<GoalsNotifier, AsyncValue<Goals>>((ref) {
  return GoalsNotifier(ref.watch(goalRepositoryProvider));
});

/// Combines goals, today's stats, this week's workouts and the live step
/// count into the fractions the dashboard ring and goal bars render.
final goalProgressProvider = Provider<AsyncValue<GoalProgress>>((ref) {
  final goalsAsync = ref.watch(goalsProvider);
  final todayStatsAsync = ref.watch(todayStatsProvider);
  final workoutsAsync = ref.watch(workoutsProvider);
  final stepState = ref.watch(stepCountProvider).valueOrNull;

  if (goalsAsync.isLoading || todayStatsAsync.isLoading || workoutsAsync.isLoading) {
    return const AsyncValue.loading();
  }
  final error = goalsAsync.hasError
      ? goalsAsync
      : (todayStatsAsync.hasError ? todayStatsAsync : workoutsAsync);
  if (error.hasError) {
    return AsyncValue.error(error.error!, error.stackTrace ?? StackTrace.current);
  }

  final goals = goalsAsync.requireValue;
  final todayStats = todayStatsAsync.requireValue;
  final workouts = workoutsAsync.requireValue;

  final (weekStart, weekEnd) = AppDateUtils.weekRange(DateTime.now());
  final thisWeek = workouts.where(
    (w) => !w.performedAt.isBefore(weekStart) && !w.performedAt.isAfter(weekEnd),
  );
  final weeklyCalories = thisWeek.fold(0.0, (sum, w) => sum + w.calories);
  final weeklyWorkoutCount = thisWeek.length;

  final steps = stepState is StepCountAvailable ? stepState.steps : 0;

  double fraction(num value, num target) =>
      target <= 0 ? 0.0 : (value / target).clamp(0.0, 1.0).toDouble();

  return AsyncValue.data(GoalProgress(
    dailyCalorieFraction: fraction(todayStats.caloriesBurned, goals.dailyCalorieTarget),
    weeklyCalorieFraction: fraction(weeklyCalories, goals.weeklyCalorieTarget),
    dailyWorkoutFraction: fraction(todayStats.workoutCount, goals.dailyWorkoutTarget),
    weeklyWorkoutFraction: fraction(weeklyWorkoutCount, goals.weeklyWorkoutTarget),
    dailyStepFraction: fraction(steps, goals.dailyStepTarget),
  ));
});
