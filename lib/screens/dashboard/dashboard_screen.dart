import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/stats.dart';
import '../../providers/goal_providers.dart';
import '../../providers/profile_providers.dart';
import '../../providers/stats_providers.dart';
import '../../providers/workout_providers.dart';
import '../../utils/constants.dart';
import '../../widgets/common/async_value_view.dart';
import '../../widgets/dashboard/dashboard_header.dart';
import '../../widgets/dashboard/recent_workouts_section.dart';
import '../../widgets/dashboard/stats_grid.dart';
import '../../widgets/dashboard/start_workout_cta.dart';
import '../../widgets/dashboard/progress_ring.dart';
import '../achievements/achievements_screen.dart';
import '../history/history_screen.dart';
import '../workout/log_workout_screen.dart';

/// The app's home tab: greeting, weekly-goal ring, quick stats, the "Start
/// Workout" call-to-action, and a preview of recent workouts.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final workoutsAsync = ref.watch(workoutsProvider);
    final todayStatsAsync = ref.watch(todayStatsProvider);
    final goalProgressAsync = ref.watch(goalProgressProvider);

    final name = profileAsync.valueOrNull?.name ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('FitTrack')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(workoutsProvider);
          ref.invalidate(profileProvider);
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: DashboardHeader(name: name)),
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.md),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Center(
                    child: AsyncValueView(
                      value: goalProgressAsync,
                      data: (context, progress) => ProgressRing(
                        progress: progress.weeklyOverallFraction,
                        centerLabel: 'This week',
                        centerSubLabel: 'of your goals',
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AsyncValueView(
                    value: todayStatsAsync,
                    data: (context, stats) => StatsGrid(
                      todayStats: stats,
                      onStreakTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AchievementsScreen()),
                      ),
                    ),
                    loading: (_) => const StatsGrid(
                      todayStats: DayStats.zero,
                      onStreakTap: _noop,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  StartWorkoutCta(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LogWorkoutScreen()),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AsyncValueView(
                    value: workoutsAsync,
                    data: (context, workouts) => RecentWorkoutsSection(
                      workouts: workouts,
                      onSeeAll: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const HistoryScreen()),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _noop() {}
