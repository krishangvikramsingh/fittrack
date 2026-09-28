import 'package:flutter/material.dart';

import '../../utils/constants.dart';

/// A live-updating preview of the calories a workout will log, recomputed
/// on every keystroke as the user fills in the form.
class CalorieEstimateCard extends StatelessWidget {
  final double calories;

  const CalorieEstimateCard({super.key, required this.calories});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Icon(Icons.local_fire_department, color: colorScheme.primary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Estimated calories burned',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onPrimaryContainer),
              ),
            ),
            Text(
              '${calories.round()} kcal',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800, color: colorScheme.primary),
            ),
          ],
        ),
      ),
    );
  }
}
