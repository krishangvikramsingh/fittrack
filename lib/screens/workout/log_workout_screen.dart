import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../models/achievement.dart';
import '../../models/exercise_type.dart';
import '../../models/workout.dart';
import '../../providers/profile_providers.dart';
import '../../providers/workout_providers.dart';
import '../../utils/calorie_calculator.dart';
import '../../utils/constants.dart';
import '../../utils/exercise_catalog.dart';
import '../../utils/validators.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/workout/calorie_estimate_card.dart';
import '../../widgets/workout/exercise_picker.dart';
import '../../widgets/workout/exercise_type_selector.dart';
import '../achievements/widgets/achievement_unlocked_dialog.dart';

const _uuid = Uuid();

/// Logs a new workout, or edits [existingWorkout] if provided. Calories are
/// estimated live via the MET formula as the user fills in the form.
class LogWorkoutScreen extends ConsumerStatefulWidget {
  final Workout? existingWorkout;

  const LogWorkoutScreen({super.key, this.existingWorkout});

  @override
  ConsumerState<LogWorkoutScreen> createState() => _LogWorkoutScreenState();
}

class _LogWorkoutScreenState extends ConsumerState<LogWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customNameController = TextEditingController();
  final _setsController = TextEditingController();
  final _repsController = TextEditingController();
  final _durationController = TextEditingController();
  final _notesController = TextEditingController();

  late ExerciseType _type;
  ExerciseDef? _catalogChoice;
  ExerciseIntensity _intensity = ExerciseIntensity.moderate;
  late DateTime _performedAt;
  bool _isSaving = false;

  bool get _isEditing => widget.existingWorkout != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingWorkout;
    if (existing == null) {
      _type = ExerciseType.cardio;
      _performedAt = DateTime.now();
      _catalogChoice = ExerciseCatalog.forType(_type).first;
    } else {
      _type = existing.type;
      _performedAt = existing.performedAt;
      _setsController.text = existing.sets?.toString() ?? '';
      _repsController.text = existing.reps?.toString() ?? '';
      _durationController.text = existing.durationMin.toString();
      _notesController.text = existing.notes ?? '';
      if (_type == ExerciseType.custom) {
        _customNameController.text = existing.exerciseName;
        _intensity = ExerciseCatalog.customIntensityMet.entries
            .firstWhere((e) => e.value == existing.met, orElse: () => ExerciseCatalog.customIntensityMet.entries.first)
            .key;
      } else {
        final catalog = ExerciseCatalog.forType(_type);
        _catalogChoice = catalog.firstWhere(
          (d) => d.name == existing.exerciseName,
          orElse: () => catalog.first,
        );
      }
    }
  }

  @override
  void dispose() {
    _customNameController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _durationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double get _met {
    if (_type == ExerciseType.custom) return ExerciseCatalog.customIntensityMet[_intensity]!;
    return _catalogChoice?.met ?? 0;
  }

  String get _exerciseName {
    if (_type == ExerciseType.custom) return _customNameController.text.trim();
    return _catalogChoice?.name ?? '';
  }

  int get _durationMin => int.tryParse(_durationController.text) ?? 0;

  double _estimatedCalories(double weightKg) =>
      CalorieCalculator.estimate(met: _met, weightKg: weightKg, durationMin: _durationMin);

  void _onTypeChanged(ExerciseType type) {
    setState(() {
      _type = type;
      if (type != ExerciseType.custom) {
        _catalogChoice = ExerciseCatalog.forType(type).first;
      }
    });
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _performedAt,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_performedAt),
    );
    if (time == null) return;
    setState(() {
      _performedAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_type == ExerciseType.custom && _exerciseName.isEmpty) return;

    setState(() => _isSaving = true);
    try {
      final weightKg = ref.read(profileProvider).valueOrNull?.weightKg ?? 70;
      final calories = _estimatedCalories(weightKg);
      final now = DateTime.now();

      final workout = Workout(
        id: widget.existingWorkout?.id ?? _uuid.v4(),
        type: _type,
        exerciseName: _exerciseName,
        sets: _type == ExerciseType.strength ? int.tryParse(_setsController.text) : null,
        reps: _type == ExerciseType.strength ? int.tryParse(_repsController.text) : null,
        durationMin: _durationMin,
        met: _met,
        calories: calories,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        performedAt: _performedAt,
        createdAt: widget.existingWorkout?.createdAt ?? now,
      );

      List<AchievementDef> newlyUnlocked = const [];
      if (_isEditing) {
        await ref.read(workoutsProvider.notifier).updateWorkout(workout);
      } else {
        newlyUnlocked = await ref.read(workoutsProvider.notifier).addWorkout(workout);
      }

      if (!mounted) return;
      Navigator.of(context).pop();

      for (final badge in newlyUnlocked) {
        await showDialog(
          context: context,
          builder: (_) => AchievementUnlockedDialog(achievement: badge),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final weightKg = ref.watch(profileProvider).valueOrNull?.weightKg ?? 70;

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Workout' : 'Log Workout')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            ExerciseTypeSelector(selected: _type, onChanged: _onTypeChanged),
            const SizedBox(height: AppSpacing.md),
            if (_type == ExerciseType.custom) ...[
              TextFormField(
                controller: _customNameController,
                decoration: const InputDecoration(labelText: 'Exercise name'),
                validator: (v) => Validators.requiredText(v, fieldName: 'Exercise name'),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Intensity', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                children: ExerciseIntensity.values.map((i) {
                  return ChoiceChip(
                    label: Text(i.label),
                    selected: _intensity == i,
                    onSelected: (_) => setState(() => _intensity = i),
                  );
                }).toList(),
              ),
            ] else
              ExercisePicker(
                type: _type,
                selected: _catalogChoice,
                onChanged: (def) => setState(() => _catalogChoice = def),
              ),
            const SizedBox(height: AppSpacing.md),
            if (_type == ExerciseType.strength)
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _setsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Sets'),
                      validator: (v) => Validators.positiveInt(v, fieldName: 'Sets'),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: TextFormField(
                      controller: _repsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Reps'),
                      validator: (v) => Validators.positiveInt(v, fieldName: 'Reps'),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
            if (_type == ExerciseType.strength) const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _durationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Duration (minutes)'),
              validator: (v) => Validators.positiveInt(v, fieldName: 'Duration'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.md),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event),
              title: const Text('Date & time'),
              subtitle: Text('${_performedAt.toLocal()}'.split('.').first),
              trailing: TextButton(onPressed: _pickDateTime, child: const Text('Change')),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
              maxLines: 2,
            ),
            const SizedBox(height: AppSpacing.md),
            CalorieEstimateCard(calories: _estimatedCalories(weightKg)),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: _isEditing ? 'Save Changes' : 'Log Workout',
              isLoading: _isSaving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
