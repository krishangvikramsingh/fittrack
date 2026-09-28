import 'package:flutter/material.dart';

import '../../../models/exercise_type.dart';
import '../../../models/history_filter.dart';
import '../../../utils/constants.dart';

/// Row of filter chips: one per [ExerciseType] (multi-select) plus a date
/// range chip that opens the platform date-range picker.
class HistoryFilterChips extends StatelessWidget {
  final HistoryFilter filter;
  final ValueChanged<HistoryFilter> onChanged;

  const HistoryFilterChips({super.key, required this.filter, required this.onChanged});

  Future<void> _pickDateRange(BuildContext context) async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 365 * 2)),
      lastDate: now,
      initialDateRange: filter.dateRange,
    );
    if (range != null) {
      onChanged(filter.copyWith(dateRange: range));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final type in ExerciseType.values)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xs),
              child: FilterChip(
                label: Text(type.label),
                selected: filter.types.contains(type),
                onSelected: (selected) {
                  final types = Set<ExerciseType>.from(filter.types);
                  selected ? types.add(type) : types.remove(type);
                  onChanged(filter.copyWith(types: types));
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.xs),
            child: InputChip(
              avatar: const Icon(Icons.date_range, size: 18),
              label: Text(filter.dateRange == null ? 'Date range' : 'Custom range'),
              selected: filter.dateRange != null,
              onSelected: (_) => _pickDateRange(context),
              onDeleted: filter.dateRange == null
                  ? null
                  : () => onChanged(filter.copyWith(clearDateRange: true)),
            ),
          ),
        ],
      ),
    );
  }
}
