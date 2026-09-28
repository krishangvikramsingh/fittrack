import 'package:flutter/material.dart';

import '../../models/exercise_type.dart';
import '../../utils/exercise_catalog.dart';

/// A dropdown of built-in exercises for the current [ExerciseType], each
/// with a fixed MET value. Not shown for [ExerciseType.custom], which lets
/// the user name their own exercise instead (see the intensity selector).
class ExercisePicker extends StatelessWidget {
  final ExerciseType type;
  final ExerciseDef? selected;
  final ValueChanged<ExerciseDef> onChanged;

  const ExercisePicker({super.key, required this.type, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final options = ExerciseCatalog.forType(type);
    return DropdownButtonFormField<ExerciseDef>(
      initialValue: selected,
      decoration: const InputDecoration(labelText: 'Exercise'),
      items: options
          .map((def) => DropdownMenuItem(value: def, child: Text(def.name)))
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
      validator: (v) => v == null ? 'Choose an exercise' : null,
    );
  }
}
