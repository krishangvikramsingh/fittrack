import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/workout.dart';
import '../../providers/workout_providers.dart';
import '../../utils/constants.dart';
import '../../widgets/common/async_value_view.dart';
import '../../widgets/common/empty_state.dart';
import '../workout/log_workout_screen.dart';
import 'widgets/grouped_workout_list.dart';
import 'widgets/history_filter_chips.dart';

/// Full, searchable and filterable list of every logged workout.
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onEdit(Workout workout) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => LogWorkoutScreen(existingWorkout: workout)),
    );
  }

  void _onDelete(Workout workout) {
    ref.read(workoutsProvider.notifier).deleteWorkout(workout.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: AppDurations.snackBar,
        content: Text('Deleted "${workout.exerciseName}"'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => ref.read(workoutsProvider.notifier).addWorkout(workout),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(historyFilterProvider);
    final filteredAsync = ref.watch(filteredWorkoutsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search exercises',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) {
                ref.read(historyFilterProvider.notifier).state = filter.copyWith(searchText: v);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: HistoryFilterChips(
              filter: filter,
              onChanged: (f) => ref.read(historyFilterProvider.notifier).state = f,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: AsyncValueView(
              value: filteredAsync,
              data: (context, workouts) {
                if (workouts.isEmpty) {
                  return EmptyState(
                    icon: Icons.search_off,
                    title: filter.isEmpty ? 'No workouts yet' : 'No matches',
                    message: filter.isEmpty
                        ? 'Workouts you log will show up here.'
                        : 'Try a different search or clear your filters.',
                  );
                }
                return GroupedWorkoutList(
                  workouts: workouts,
                  onTapWorkout: _onEdit,
                  onDeleteWorkout: _onDelete,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
