import 'package:flutter/material.dart';

import '../../../models/workout.dart';
import '../../../utils/constants.dart';
import '../../../utils/date_utils.dart';
import '../../../widgets/workout/workout_tile.dart';

/// Renders workouts grouped by calendar day (newest day first), each with a
/// swipe-to-delete affordance and a tap-to-edit callback.
class GroupedWorkoutList extends StatelessWidget {
  final List<Workout> workouts;
  final void Function(Workout workout) onTapWorkout;
  final void Function(Workout workout) onDeleteWorkout;

  const GroupedWorkoutList({
    super.key,
    required this.workouts,
    required this.onTapWorkout,
    required this.onDeleteWorkout,
  });

  Map<DateTime, List<Workout>> _groupByDay() {
    final groups = <DateTime, List<Workout>>{};
    for (final w in workouts) {
      final day = AppDateUtils.startOfDay(w.performedAt);
      groups.putIfAbsent(day, () => []).add(w);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final groups = _groupByDay();
    final days = groups.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: days.length,
      itemBuilder: (context, index) {
        final day = days[index];
        final dayWorkouts = groups[day]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs, top: AppSpacing.sm),
              child: Text(
                AppDateUtils.dayMonthYearFormat.format(day),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            for (final w in dayWorkouts)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Dismissible(
                  key: ValueKey(w.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                    ),
                    child: Icon(Icons.delete, color: Theme.of(context).colorScheme.onErrorContainer),
                  ),
                  onDismissed: (_) => onDeleteWorkout(w),
                  child: WorkoutTile(workout: w, onTap: () => onTapWorkout(w)),
                ),
              ),
          ],
        );
      },
    );
  }
}
