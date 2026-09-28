import 'package:flutter/material.dart';

import '../../models/exercise_type.dart';
import '../../models/workout.dart';
import '../../utils/constants.dart';
import '../../utils/date_utils.dart';

/// A single row representing one logged workout - used on the dashboard's
/// "recent workouts" list and in the full history list.
class WorkoutTile extends StatelessWidget {
  final Workout workout;
  final VoidCallback? onTap;

  const WorkoutTile({super.key, required this.workout, this.onTap});

  static const Map<ExerciseType, IconData> _icons = {
    ExerciseType.cardio: Icons.directions_run,
    ExerciseType.strength: Icons.fitness_center,
    ExerciseType.yoga: Icons.self_improvement,
    ExerciseType.custom: Icons.sports_gymnastics,
  };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final subtitleParts = <String>[
      '${workout.durationMin} min',
      if (workout.sets != null && workout.reps != null)
        '${workout.sets}x${workout.reps}',
      AppDateUtils.timeFormat.format(workout.performedAt),
    ];

    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          child: Icon(_icons[workout.type], color: colorScheme.primary),
        ),
        title: Text(workout.exerciseName, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitleParts.join(' • ')),
        trailing: Text(
          '${workout.calories.round()} kcal',
          style: TextStyle(fontWeight: FontWeight.w700, color: colorScheme.primary),
        ),
      ),
    );
  }
}
