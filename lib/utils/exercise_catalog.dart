import '../models/exercise_type.dart';

/// A named exercise with its fixed MET (Metabolic Equivalent of Task) value,
/// used to look up calorie burn without asking the user to pick an
/// intensity every time.
class ExerciseDef {
  final String name;
  final ExerciseType type;
  final double met;

  const ExerciseDef({required this.name, required this.type, required this.met});
}

/// The built-in library of exercises offered in the "Log Workout" picker,
/// grouped by [ExerciseType]. Values are standard MET scores from the
/// Compendium of Physical Activities.
///
/// [ExerciseType.custom] has no fixed entries here - the user names their own
/// exercise and picks an [ExerciseIntensity] instead, which maps to
/// [customIntensityMet].
class ExerciseCatalog {
  ExerciseCatalog._();

  static const List<ExerciseDef> cardio = [
    ExerciseDef(name: 'Running', type: ExerciseType.cardio, met: 9.8),
    ExerciseDef(name: 'Cycling', type: ExerciseType.cardio, met: 7.5),
    ExerciseDef(name: 'Walking', type: ExerciseType.cardio, met: 3.5),
    ExerciseDef(name: 'Swimming', type: ExerciseType.cardio, met: 8.0),
    ExerciseDef(name: 'Jump Rope', type: ExerciseType.cardio, met: 12.3),
  ];

  static const List<ExerciseDef> strength = [
    ExerciseDef(name: 'Weight Lifting', type: ExerciseType.strength, met: 5.0),
    ExerciseDef(name: 'Bodyweight Training', type: ExerciseType.strength, met: 3.8),
  ];

  static const List<ExerciseDef> yoga = [
    ExerciseDef(name: 'Hatha Yoga', type: ExerciseType.yoga, met: 2.5),
    ExerciseDef(name: 'Power Yoga', type: ExerciseType.yoga, met: 4.0),
  ];

  static const Map<ExerciseIntensity, double> customIntensityMet = {
    ExerciseIntensity.light: 3.0,
    ExerciseIntensity.moderate: 5.0,
    ExerciseIntensity.vigorous: 8.0,
  };

  static List<ExerciseDef> forType(ExerciseType type) => switch (type) {
        ExerciseType.cardio => cardio,
        ExerciseType.strength => strength,
        ExerciseType.yoga => yoga,
        ExerciseType.custom => const [],
      };
}
