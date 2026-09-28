import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/goals.dart';
import '../../providers/goal_providers.dart';
import '../../utils/constants.dart';
import '../../widgets/common/async_value_view.dart';
import '../../widgets/common/primary_button.dart';

/// Lets the user edit their daily/weekly targets, with live progress bars
/// showing where they currently stand against each one.
class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalsProvider);
    final progressAsync = ref.watch(goalProgressProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Goals')),
      body: AsyncValueView(
        value: goalsAsync,
        data: (context, goals) => _GoalsForm(
          goals: goals,
          progress: progressAsync.valueOrNull,
        ),
      ),
    );
  }
}

class _GoalsForm extends ConsumerStatefulWidget {
  final Goals goals;
  final GoalProgress? progress;

  const _GoalsForm({required this.goals, required this.progress});

  @override
  ConsumerState<_GoalsForm> createState() => _GoalsFormState();
}

class _GoalsFormState extends ConsumerState<_GoalsForm> {
  late double _dailyCalories = widget.goals.dailyCalorieTarget.toDouble();
  late double _weeklyCalories = widget.goals.weeklyCalorieTarget.toDouble();
  late int _dailyWorkouts = widget.goals.dailyWorkoutTarget;
  late int _weeklyWorkouts = widget.goals.weeklyWorkoutTarget;
  late double _dailySteps = widget.goals.dailyStepTarget.toDouble();
  bool _isSaving = false;

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      await ref.read(goalsProvider.notifier).updateGoals(widget.goals.copyWith(
            dailyCalorieTarget: _dailyCalories.round(),
            weeklyCalorieTarget: _weeklyCalories.round(),
            dailyWorkoutTarget: _dailyWorkouts,
            weeklyWorkoutTarget: _weeklyWorkouts,
            dailyStepTarget: _dailySteps.round(),
          ));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Goals updated')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _GoalSlider(
          label: 'Daily calorie target',
          value: _dailyCalories,
          min: 100,
          max: 1500,
          valueLabel: '${_dailyCalories.round()} kcal',
          progress: widget.progress?.dailyCalorieFraction,
          onChanged: (v) => setState(() => _dailyCalories = v),
        ),
        _GoalSlider(
          label: 'Weekly calorie target',
          value: _weeklyCalories,
          min: 500,
          max: 8000,
          valueLabel: '${_weeklyCalories.round()} kcal',
          progress: widget.progress?.weeklyCalorieFraction,
          onChanged: (v) => setState(() => _weeklyCalories = v),
        ),
        _GoalSlider(
          label: 'Daily workout target',
          value: _dailyWorkouts.toDouble(),
          min: 0,
          max: 3,
          divisions: 3,
          valueLabel: '$_dailyWorkouts workout(s)',
          progress: widget.progress?.dailyWorkoutFraction,
          onChanged: (v) => setState(() => _dailyWorkouts = v.round()),
        ),
        _GoalSlider(
          label: 'Weekly workout target',
          value: _weeklyWorkouts.toDouble(),
          min: 1,
          max: 14,
          divisions: 13,
          valueLabel: '$_weeklyWorkouts workout(s)',
          progress: widget.progress?.weeklyWorkoutFraction,
          onChanged: (v) => setState(() => _weeklyWorkouts = v.round()),
        ),
        _GoalSlider(
          label: 'Daily step target',
          value: _dailySteps,
          min: 2000,
          max: 20000,
          valueLabel: '${_dailySteps.round()} steps',
          progress: widget.progress?.dailyStepFraction,
          onChanged: (v) => setState(() => _dailySteps = v),
        ),
        const SizedBox(height: AppSpacing.md),
        PrimaryButton(label: 'Save Goals', isLoading: _isSaving, onPressed: _save),
      ],
    );
  }
}

class _GoalSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final String valueLabel;
  final double? progress;
  final ValueChanged<double> onChanged;

  const _GoalSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.valueLabel,
    required this.onChanged,
    this.divisions,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelLarge),
                Text(valueLabel, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
            Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
            if (progress != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(value: progress, minHeight: 6),
              ),
          ],
        ),
      ),
    );
  }
}
