/// The four broad categories a logged workout can fall into.
///
/// Stored in the database as its [name] (e.g. `"cardio"`), which keeps rows
/// human-readable when inspecting the sqlite file directly.
enum ExerciseType {
  cardio,
  strength,
  yoga,
  custom;

  String get label => switch (this) {
        ExerciseType.cardio => 'Cardio',
        ExerciseType.strength => 'Strength',
        ExerciseType.yoga => 'Yoga',
        ExerciseType.custom => 'Custom',
      };

  static ExerciseType fromName(String name) =>
      ExerciseType.values.firstWhere(
        (e) => e.name == name,
        orElse: () => ExerciseType.custom,
      );
}

/// Perceived effort for a custom exercise, used to pick a MET value when the
/// exercise isn't in [ExerciseCatalog].
enum ExerciseIntensity {
  light,
  moderate,
  vigorous;

  String get label => switch (this) {
        ExerciseIntensity.light => 'Light',
        ExerciseIntensity.moderate => 'Moderate',
        ExerciseIntensity.vigorous => 'Vigorous',
      };

  static ExerciseIntensity fromName(String name) =>
      ExerciseIntensity.values.firstWhere(
        (e) => e.name == name,
        orElse: () => ExerciseIntensity.moderate,
      );
}
