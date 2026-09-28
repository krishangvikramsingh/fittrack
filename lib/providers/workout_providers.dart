import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/achievement.dart';
import '../models/history_filter.dart';
import '../models/workout.dart';
import '../repositories/workout_repository.dart';
import '../utils/date_utils.dart';
import 'achievement_providers.dart';
import 'core_providers.dart';

/// Holds every logged workout, newest first. Add/update/delete all re-fetch
/// the full list afterward rather than patching state locally - the table is
/// small enough (a personal fitness log, not a shared dataset) that this
/// keeps the notifier simple and always consistent with the database.
class WorkoutsNotifier extends StateNotifier<AsyncValue<List<Workout>>> {
  final WorkoutRepository _repo;
  final Ref _ref;

  WorkoutsNotifier(this._repo, this._ref) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.getAll());
  }

  /// Saves the workout, refreshes the list, then checks whether it earned
  /// any new achievements. Returns the badges unlocked by this save (empty
  /// if none), so the calling screen can show an "unlocked!" celebration.
  Future<List<AchievementDef>> addWorkout(Workout workout) async {
    await _repo.insert(workout);
    await _load();
    return _ref.read(achievementsProvider.notifier).evaluate();
  }

  Future<void> updateWorkout(Workout workout) async {
    await _repo.update(workout);
    await _load();
  }

  Future<void> deleteWorkout(String id) async {
    await _repo.delete(id);
    await _load();
  }
}

final workoutsProvider = StateNotifierProvider<WorkoutsNotifier, AsyncValue<List<Workout>>>((ref) {
  return WorkoutsNotifier(ref.watch(workoutRepositoryProvider), ref);
});

/// The current search/filter state for the History screen.
final historyFilterProvider = StateProvider<HistoryFilter>((ref) => const HistoryFilter());

/// [workoutsProvider]'s list after [historyFilterProvider] is applied.
final filteredWorkoutsProvider = Provider<AsyncValue<List<Workout>>>((ref) {
  final filter = ref.watch(historyFilterProvider);
  return ref.watch(workoutsProvider).whenData((workouts) {
    return workouts.where((w) {
      if (filter.types.isNotEmpty && !filter.types.contains(w.type)) {
        return false;
      }
      if (filter.searchText.trim().isNotEmpty &&
          !w.exerciseName.toLowerCase().contains(filter.searchText.trim().toLowerCase())) {
        return false;
      }
      final range = filter.dateRange;
      if (range != null) {
        final day = AppDateUtils.startOfDay(w.performedAt);
        if (day.isBefore(AppDateUtils.startOfDay(range.start)) ||
            day.isAfter(AppDateUtils.startOfDay(range.end))) {
          return false;
        }
      }
      return true;
    }).toList();
  });
});
