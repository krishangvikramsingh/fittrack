/// The user's consecutive-day workout streak, as computed by
/// `StreakCalculator` from the distinct set of workout dates.
class StreakInfo {
  final int currentStreak;
  final int longestStreak;

  const StreakInfo({required this.currentStreak, required this.longestStreak});

  static const zero = StreakInfo(currentStreak: 0, longestStreak: 0);
}
