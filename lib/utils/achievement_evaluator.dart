import '../utils/constants.dart';

/// Pure rule engine mapping lifetime stats to the set of achievement codes
/// that should be unlocked. Badges are permanent once earned, so streak
/// checks use the user's *longest ever* streak, not the current one - losing
/// a streak must never take a badge away.
class AchievementEvaluator {
  AchievementEvaluator._();

  /// Returns every code that *should* be unlocked given these stats
  /// (including ones already unlocked). Callers diff this against what's
  /// already persisted to find newly-earned badges.
  static Set<String> evaluate({
    required int totalWorkouts,
    required int longestStreak,
    required double totalCaloriesBurned,
    required int maxStepsInADay,
  }) {
    final unlocked = <String>{};

    if (totalWorkouts >= 1) unlocked.add(AchievementCodes.firstWorkout);
    if (totalWorkouts >= 10) unlocked.add(AchievementCodes.workouts10);
    if (totalWorkouts >= 50) unlocked.add(AchievementCodes.workouts50);

    if (longestStreak >= 3) unlocked.add(AchievementCodes.streak3);
    if (longestStreak >= 7) unlocked.add(AchievementCodes.streak7);
    if (longestStreak >= 30) unlocked.add(AchievementCodes.streak30);

    if (totalCaloriesBurned >= 5000) unlocked.add(AchievementCodes.calories5000);
    if (maxStepsInADay >= 10000) unlocked.add(AchievementCodes.steps10k);

    return unlocked;
  }

  /// Codes present in [evaluate]'s result but not yet in [alreadyUnlocked] -
  /// i.e. badges earned just now that should trigger an "unlocked!" moment.
  static Set<String> newlyUnlocked({
    required Set<String> eligible,
    required Set<String> alreadyUnlocked,
  }) {
    return eligible.difference(alreadyUnlocked);
  }
}
