import 'package:flutter/material.dart';

import '../../../models/achievement.dart';
import '../../../utils/constants.dart';

/// A short celebratory dialog shown right after a workout (or step count)
/// unlocks a new badge.
class AchievementUnlockedDialog extends StatelessWidget {
  final AchievementDef achievement;

  const AchievementUnlockedDialog({super.key, required this.achievement});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AlertDialog(
      icon: CircleAvatar(
        radius: 32,
        backgroundColor: colorScheme.primaryContainer,
        child: Icon(achievement.icon, size: 32, color: colorScheme.primary),
      ),
      title: const Text('Achievement unlocked!', textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            achievement.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(achievement.description, textAlign: TextAlign.center),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        FilledButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Nice!')),
      ],
    );
  }
}
