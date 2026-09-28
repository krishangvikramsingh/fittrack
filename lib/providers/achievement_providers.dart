import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/achievement.dart';
import '../repositories/achievement_repository.dart';
import '../repositories/step_repository.dart';
import '../repositories/workout_repository.dart';
import '../utils/achievement_evaluator.dart';
import '../utils/streak_calculator.dart';
import 'core_providers.dart';

/// Holds every badge in [AchievementCatalog], each paired with its unlock
/// state. [evaluate] is the single entry point that re-checks lifetime stats
/// against [AchievementEvaluator]'s rules and persists any newly-earned
/// badges - called after every workout save and every step-count update.
class AchievementsNotifier extends StateNotifier<AsyncValue<List<AchievementStatus>>> {
  final AchievementRepository _achievementRepo;
  final WorkoutRepository _workoutRepo;
  final StepRepository _stepRepo;

  AchievementsNotifier(this._achievementRepo, this._workoutRepo, this._stepRepo)
      : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    state = await AsyncValue.guard(() async {
      final unlocked = await _achievementRepo.getUnlocked();
      return AchievementCatalog.all
          .map((def) => AchievementStatus(def: def, unlockedAt: unlocked[def.code]))
          .toList();
    });
  }

  /// Re-evaluates lifetime stats, persists any newly-unlocked badges, and
  /// returns their definitions so the caller can show a celebration.
  Future<List<AchievementDef>> evaluate() async {
    final workouts = await _workoutRepo.getAll();
    final streak = StreakCalculator.compute(workouts.map((w) => w.performedAt).toList());
    final totalCalories = await _workoutRepo.totalCaloriesBurned();
    final maxSteps = await _stepRepo.maxStepsInADay();
    final alreadyUnlocked = await _achievementRepo.getUnlocked();

    final eligible = AchievementEvaluator.evaluate(
      totalWorkouts: workouts.length,
      longestStreak: streak.longestStreak,
      totalCaloriesBurned: totalCalories,
      maxStepsInADay: maxSteps,
    );
    final newly = AchievementEvaluator.newlyUnlocked(
      eligible: eligible,
      alreadyUnlocked: alreadyUnlocked.keys.toSet(),
    );

    if (newly.isEmpty) return const [];

    final now = DateTime.now();
    for (final code in newly) {
      await _achievementRepo.unlock(code, now);
    }
    await _load();
    return newly.map(AchievementCatalog.byCode).toList();
  }
}

final achievementsProvider =
    StateNotifierProvider<AchievementsNotifier, AsyncValue<List<AchievementStatus>>>((ref) {
  return AchievementsNotifier(
    ref.watch(achievementRepositoryProvider),
    ref.watch(workoutRepositoryProvider),
    ref.watch(stepRepositoryProvider),
  );
});
