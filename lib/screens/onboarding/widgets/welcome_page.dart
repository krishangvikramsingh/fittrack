import 'package:flutter/material.dart';

import '../../../utils/constants.dart';

/// The first onboarding page: a friendly introduction to the app.
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 56,
            backgroundColor: colorScheme.primaryContainer,
            child: Icon(Icons.fitness_center, size: 56, color: colorScheme.primary),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Welcome to FitTrack',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Log workouts, track your steps, hit your goals, and build a '
            'streak - all stored privately on your device.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
