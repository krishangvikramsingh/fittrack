import 'package:flutter/material.dart';

import '../../../models/user_profile.dart';
import '../../../utils/constants.dart';
import '../../../utils/validators.dart';
import 'goal_selector.dart';

/// Onboarding page 3: height, weight (metric only - unit switching is a
/// display-only Settings feature, so onboarding keeps units simple) and
/// fitness goal.
class BodyMetricsPage extends StatelessWidget {
  final TextEditingController heightController;
  final TextEditingController weightController;
  final FitnessGoal? goal;
  final ValueChanged<FitnessGoal> onGoalChanged;

  const BodyMetricsPage({
    super.key,
    required this.heightController,
    required this.weightController,
    required this.goal,
    required this.onGoalChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your body metrics', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: heightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Height (cm)'),
                  validator: (v) => Validators.positiveDouble(v, fieldName: 'Height'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: TextFormField(
                  controller: weightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Weight (kg)'),
                  validator: (v) => Validators.positiveDouble(v, fieldName: 'Weight'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Fitness goal', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          GoalSelector(selected: goal, onChanged: onGoalChanged),
        ],
      ),
    );
  }
}
