import 'package:flutter/material.dart';

import '../../../models/streak_info.dart';
import '../../../utils/constants.dart';

/// Shows the user's current and longest workout streak at the top of the
/// Achievements screen.
class StreakBanner extends StatelessWidget {
  final StreakInfo streak;

  const StreakBanner({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Icon(Icons.local_fire_department, size: 40, color: Colors.orange),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${streak.currentStreak}-day streak',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    'Longest: ${streak.longestStreak} days',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
