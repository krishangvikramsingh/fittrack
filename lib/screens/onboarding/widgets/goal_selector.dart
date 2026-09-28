import 'package:flutter/material.dart';

import '../../../models/user_profile.dart';
import '../../../utils/constants.dart';

/// A vertical stack of selectable cards for choosing a [FitnessGoal].
class GoalSelector extends StatelessWidget {
  final FitnessGoal? selected;
  final ValueChanged<FitnessGoal> onChanged;

  const GoalSelector({super.key, required this.selected, required this.onChanged});

  static const Map<FitnessGoal, IconData> _icons = {
    FitnessGoal.lose: Icons.trending_down,
    FitnessGoal.maintain: Icons.trending_flat,
    FitnessGoal.gain: Icons.trending_up,
  };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: FitnessGoal.values.map((goal) {
        final isSelected = selected == goal;
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            onTap: () => onChanged(goal),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                color: isSelected ? colorScheme.primaryContainer : colorScheme.surfaceContainerHigh,
                border: Border.all(
                  color: isSelected ? colorScheme.primary : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(_icons[goal], color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant),
                  const SizedBox(width: AppSpacing.md),
                  Text(goal.label, style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
