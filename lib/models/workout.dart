import 'exercise_type.dart';

/// A single logged workout session.
///
/// [sets]/[reps] are only meaningful for [ExerciseType.strength] and are left
/// null otherwise. [met] is stored alongside the computed [calories] so
/// history and charts don't need to re-derive it if the exercise catalog
/// changes later.
class Workout {
  final String id;
  final ExerciseType type;
  final String exerciseName;
  final int? sets;
  final int? reps;
  final int durationMin;
  final double met;
  final double calories;
  final String? notes;
  final DateTime performedAt;
  final DateTime createdAt;

  const Workout({
    required this.id,
    required this.type,
    required this.exerciseName,
    this.sets,
    this.reps,
    required this.durationMin,
    required this.met,
    required this.calories,
    this.notes,
    required this.performedAt,
    required this.createdAt,
  });

  Workout copyWith({
    ExerciseType? type,
    String? exerciseName,
    int? sets,
    int? reps,
    bool clearSetsReps = false,
    int? durationMin,
    double? met,
    double? calories,
    String? notes,
    DateTime? performedAt,
  }) {
    return Workout(
      id: id,
      type: type ?? this.type,
      exerciseName: exerciseName ?? this.exerciseName,
      sets: clearSetsReps ? null : (sets ?? this.sets),
      reps: clearSetsReps ? null : (reps ?? this.reps),
      durationMin: durationMin ?? this.durationMin,
      met: met ?? this.met,
      calories: calories ?? this.calories,
      notes: notes ?? this.notes,
      performedAt: performedAt ?? this.performedAt,
      createdAt: createdAt,
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'type': type.name,
        'exercise_name': exerciseName,
        'sets': sets,
        'reps': reps,
        'duration_min': durationMin,
        'met': met,
        'calories': calories,
        'notes': notes,
        'performed_at': performedAt.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
      };

  factory Workout.fromMap(Map<String, Object?> map) => Workout(
        id: map['id']! as String,
        type: ExerciseType.fromName(map['type']! as String),
        exerciseName: map['exercise_name']! as String,
        sets: map['sets'] as int?,
        reps: map['reps'] as int?,
        durationMin: map['duration_min']! as int,
        met: (map['met']! as num).toDouble(),
        calories: (map['calories']! as num).toDouble(),
        notes: map['notes'] as String?,
        performedAt: DateTime.parse(map['performed_at']! as String),
        createdAt: DateTime.parse(map['created_at']! as String),
      );
}
