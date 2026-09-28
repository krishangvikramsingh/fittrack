import 'package:flutter/material.dart';

import '../../../models/user_profile.dart';
import '../../../utils/constants.dart';

/// A row of selectable chips for choosing [Gender].
class GenderSelector extends StatelessWidget {
  final Gender? selected;
  final ValueChanged<Gender> onChanged;

  const GenderSelector({super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      children: Gender.values.map((g) {
        return ChoiceChip(
          label: Text(g.label),
          selected: selected == g,
          onSelected: (_) => onChanged(g),
        );
      }).toList(),
    );
  }
}
