import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/streak_info.dart';
import '../utils/streak_calculator.dart';
import 'workout_providers.dart';

/// The user's current and longest workout streak, derived from
/// [workoutsProvider]'s distinct set of workout dates.
final streakProvider = Provider<AsyncValue<StreakInfo>>((ref) {
  return ref.watch(workoutsProvider).whenData((workouts) {
    return StreakCalculator.compute(workouts.map((w) => w.performedAt).toList());
  });
});
