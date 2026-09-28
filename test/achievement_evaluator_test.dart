import 'package:flutter_test/flutter_test.dart';
import 'package:fittrack/utils/achievement_evaluator.dart';
import 'package:fittrack/utils/constants.dart';

void main() {
  group('AchievementEvaluator.evaluate', () {
    test('no stats unlocks nothing', () {
      final result = AchievementEvaluator.evaluate(
        totalWorkouts: 0,
        longestStreak: 0,
        totalCaloriesBurned: 0,
        maxStepsInADay: 0,
      );
      expect(result, isEmpty);
    });

    test('first workout unlocks only the first-workout badge', () {
      final result = AchievementEvaluator.evaluate(
        totalWorkouts: 1,
        longestStreak: 0,
        totalCaloriesBurned: 100,
        maxStepsInADay: 500,
      );
      expect(result, {AchievementCodes.firstWorkout});
    });

    test('10 workouts unlocks both first-workout and 10-workouts badges', () {
      final result = AchievementEvaluator.evaluate(
        totalWorkouts: 10,
        longestStreak: 0,
        totalCaloriesBurned: 0,
        maxStepsInADay: 0,
      );
      expect(result, {AchievementCodes.firstWorkout, AchievementCodes.workouts10});
    });

    test('streak badges unlock cumulatively at their thresholds', () {
      final result = AchievementEvaluator.evaluate(
        totalWorkouts: 0,
        longestStreak: 7,
        totalCaloriesBurned: 0,
        maxStepsInADay: 0,
      );
      expect(result, {AchievementCodes.streak3, AchievementCodes.streak7});
      expect(result, isNot(contains(AchievementCodes.streak30)));
    });

    test('streak badge stays earned even if longestStreak was reached once', () {
      // Regression guard: badges must key off *longest* streak, not current,
      // so losing today's streak never revokes a past achievement.
      final result = AchievementEvaluator.evaluate(
        totalWorkouts: 0,
        longestStreak: 30,
        totalCaloriesBurned: 0,
        maxStepsInADay: 0,
      );
      expect(result, containsAll({
        AchievementCodes.streak3,
        AchievementCodes.streak7,
        AchievementCodes.streak30,
      }));
    });

    test('calorie and step thresholds unlock independently', () {
      final result = AchievementEvaluator.evaluate(
        totalWorkouts: 0,
        longestStreak: 0,
        totalCaloriesBurned: 5000,
        maxStepsInADay: 10000,
      );
      expect(result, {AchievementCodes.calories5000, AchievementCodes.steps10k});
    });
  });

  group('AchievementEvaluator.newlyUnlocked', () {
    test('returns only codes not already unlocked', () {
      final newly = AchievementEvaluator.newlyUnlocked(
        eligible: {AchievementCodes.firstWorkout, AchievementCodes.workouts10},
        alreadyUnlocked: {AchievementCodes.firstWorkout},
      );
      expect(newly, {AchievementCodes.workouts10});
    });

    test('returns empty when nothing new was earned', () {
      final newly = AchievementEvaluator.newlyUnlocked(
        eligible: {AchievementCodes.firstWorkout},
        alreadyUnlocked: {AchievementCodes.firstWorkout},
      );
      expect(newly, isEmpty);
    });
  });
}
