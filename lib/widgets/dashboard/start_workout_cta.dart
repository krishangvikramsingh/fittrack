import 'package:flutter/material.dart';

import '../../utils/constants.dart';

/// The prominent gradient call-to-action card that launches the workout
/// logging flow.
class StartWorkoutCta extends StatelessWidget {
  final VoidCallback onTap;

  const StartWorkoutCta({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          gradient: LinearGradient(
            colors: [colorScheme.primary, colorScheme.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Start a Workout',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: colorScheme.onPrimary, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Log an exercise and track your calories',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: colorScheme.onPrimary.withValues(alpha: 0.9)),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_circle_right, color: colorScheme.onPrimary, size: 36),
          ],
        ),
      ),
    );
  }
}
