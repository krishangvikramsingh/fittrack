import '../models/streak_info.dart';

/// Computes consecutive-day workout streaks from a list of workout
/// timestamps. Pure function of the distinct calendar dates a workout was
/// logged on - no I/O, so it's fully unit-testable.
class StreakCalculator {
  StreakCalculator._();

  static DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  /// [workoutTimestamps] may contain duplicate days and need not be sorted.
  ///
  /// The current streak counts backward from *today* if today already has a
  /// workout, or from *yesterday* if it doesn't (so logging nothing yet today
  /// doesn't reset the streak to zero before the day is even over). Any gap
  /// beyond that breaks the streak.
  static StreakInfo compute(List<DateTime> workoutTimestamps, {DateTime? now}) {
    if (workoutTimestamps.isEmpty) return StreakInfo.zero;

    final days = workoutTimestamps.map(_dateOnly).toSet();
    final sortedAsc = days.toList()..sort();

    // Longest streak: scan ascending, counting consecutive-day runs.
    var longest = 1;
    var run = 1;
    for (var i = 1; i < sortedAsc.length; i++) {
      final gap = sortedAsc[i].difference(sortedAsc[i - 1]).inDays;
      if (gap == 1) {
        run++;
      } else if (gap > 1) {
        run = 1;
      }
      if (run > longest) longest = run;
    }

    // Current streak: walk backward from today (or yesterday) while each day
    // is present in the set.
    final today = _dateOnly(now ?? DateTime.now());
    var cursor = days.contains(today) ? today : today.subtract(const Duration(days: 1));
    var current = 0;
    while (days.contains(cursor)) {
      current++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return StreakInfo(currentStreak: current, longestStreak: longest);
  }
}
