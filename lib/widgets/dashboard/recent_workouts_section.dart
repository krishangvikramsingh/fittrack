import 'package:flutter/material.dart';

import '../../models/workout.dart';
import '../../utils/constants.dart';
import '../common/empty_state.dart';
import '../common/section_header.dart';
import '../workout/workout_tile.dart';

/// Shows the 3 most recent workouts, or a friendly empty state if none have
/// been logged yet.
class RecentWorkoutsSection extends StatelessWidget {
  final List<Workout> workouts;
  final VoidCallback onSeeAll;

  const RecentWorkoutsSection({super.key, required this.workouts, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final recent = workouts.take(3).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Recent workouts',
          trailing: workouts.isEmpty
              ? null
              : TextButton(onPressed: onSeeAll, child: const Text('See all')),
        ),
        if (recent.isEmpty)
          const EmptyState(
            icon: Icons.fitness_center,
            title: 'No workouts yet',
            message: "Tap \"Start a Workout\" above to log your first session.",
          )
        else
          Column(
            children: [
              for (final w in recent)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: WorkoutTile(workout: w),
                ),
            ],
          ),
      ],
    );
  }
}
