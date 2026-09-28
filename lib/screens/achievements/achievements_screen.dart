import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/achievement_providers.dart';
import '../../providers/streak_providers.dart';
import '../../utils/constants.dart';
import '../../widgets/common/async_value_view.dart';
import 'widgets/badge_tile.dart';
import 'widgets/streak_banner.dart';

/// Shows the user's streak plus every badge in the catalog, unlocked or not.
class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakAsync = ref.watch(streakProvider);
    final achievementsAsync = ref.watch(achievementsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Achievements')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          AsyncValueView(
            value: streakAsync,
            data: (context, streak) => StreakBanner(streak: streak),
          ),
          const SizedBox(height: AppSpacing.lg),
          AsyncValueView(
            value: achievementsAsync,
            data: (context, achievements) => GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppSpacing.sm,
              crossAxisSpacing: AppSpacing.sm,
              childAspectRatio: 0.95,
              children: [
                for (final status in achievements) BadgeTile(status: status),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
