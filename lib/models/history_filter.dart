import 'package:flutter/material.dart' show DateTimeRange;

import 'exercise_type.dart';

/// The active search/filter state for the workout history screen.
class HistoryFilter {
  final String searchText;
  final Set<ExerciseType> types;
  final DateTimeRange? dateRange;

  const HistoryFilter({
    this.searchText = '',
    this.types = const {},
    this.dateRange,
  });

  bool get isEmpty =>
      searchText.isEmpty && types.isEmpty && dateRange == null;

  HistoryFilter copyWith({
    String? searchText,
    Set<ExerciseType>? types,
    DateTimeRange? dateRange,
    bool clearDateRange = false,
  }) {
    return HistoryFilter(
      searchText: searchText ?? this.searchText,
      types: types ?? this.types,
      dateRange: clearDateRange ? null : (dateRange ?? this.dateRange),
    );
  }
}
