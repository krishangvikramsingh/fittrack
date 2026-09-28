import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/stats.dart';
import '../utils/date_utils.dart';
import 'workout_providers.dart';

/// Today's calories/workout-count/minutes, derived from [workoutsProvider].
final todayStatsProvider = Provider<AsyncValue<DayStats>>((ref) {
  return ref.watch(workoutsProvider).whenData((workouts) {
    final today = DateTime.now();
    final todays = workouts.where((w) => AppDateUtils.isSameDay(w.performedAt, today));
    return DayStats(
      caloriesBurned: todays.fold(0.0, (sum, w) => sum + w.calories),
      workoutCount: todays.length,
      totalMinutes: todays.fold(0, (sum, w) => sum + w.durationMin),
    );
  });
});

/// The last 7 days of calories burned (oldest first), one bar per day, for
/// the dashboard/progress weekly chart.
final weeklyCaloriesProvider = Provider<AsyncValue<List<DailyTotal>>>((ref) {
  return ref.watch(workoutsProvider).whenData((workouts) {
    final today = AppDateUtils.startOfDay(DateTime.now());
    return List.generate(7, (i) {
      final day = today.subtract(Duration(days: 6 - i));
      final total = workouts
          .where((w) => AppDateUtils.isSameDay(w.performedAt, day))
          .fold(0.0, (sum, w) => sum + w.calories);
      return DailyTotal(date: day, calories: total);
    });
  });
});
