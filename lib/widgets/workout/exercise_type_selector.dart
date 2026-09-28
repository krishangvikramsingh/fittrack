import 'package:flutter/material.dart';

import '../../models/exercise_type.dart';

/// A segmented control for picking the broad category of a workout.
class ExerciseTypeSelector extends StatelessWidget {
  final ExerciseType selected;
  final ValueChanged<ExerciseType> onChanged;

  const ExerciseTypeSelector({super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ExerciseType>(
      segments: ExerciseType.values
          .map((t) => ButtonSegment(value: t, label: Text(t.label)))
          .toList(),
      selected: {selected},
      onSelectionChanged: (set) => onChanged(set.first),
      showSelectedIcon: false,
    );
  }
}
