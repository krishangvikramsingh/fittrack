import 'package:flutter/material.dart';

import '../../../models/achievement.dart';
import '../../../utils/constants.dart';
import '../../../utils/date_utils.dart';

/// A single badge in the achievements grid: full color with an unlock date
/// if earned, greyed out otherwise.
class BadgeTile extends StatelessWidget {
  final AchievementStatus status;

  const BadgeTile({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isUnlocked = status.isUnlocked;

    return Card(
      color: isUnlocked ? colorScheme.primaryContainer : colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              status.def.icon,
              size: 36,
              color: isUnlocked ? colorScheme.primary : colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              status.def.title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isUnlocked ? null : colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              isUnlocked
                  ? 'Unlocked ${AppDateUtils.dayMonthFormat.format(status.unlockedAt!)}'
                  : status.def.description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
