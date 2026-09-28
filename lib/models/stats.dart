/// Aggregate stats for "today", shown on the dashboard.
class DayStats {
  final double caloriesBurned;
  final int workoutCount;
  final int totalMinutes;

  const DayStats({
    required this.caloriesBurned,
    required this.workoutCount,
    required this.totalMinutes,
  });

  static const zero = DayStats(caloriesBurned: 0, workoutCount: 0, totalMinutes: 0);
}

/// Calories burned on a single calendar day - one bar in the weekly chart.
class DailyTotal {
  final DateTime date;
  final double calories;

  const DailyTotal({required this.date, required this.calories});
}
