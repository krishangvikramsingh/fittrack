import '../utils/constants.dart';

/// The single-row set of user-defined daily/weekly targets.
class Goals {
  final int dailyCalorieTarget;
  final int weeklyCalorieTarget;
  final int dailyWorkoutTarget;
  final int weeklyWorkoutTarget;
  final int dailyStepTarget;
  final DateTime updatedAt;

  const Goals({
    required this.dailyCalorieTarget,
    required this.weeklyCalorieTarget,
    required this.dailyWorkoutTarget,
    required this.weeklyWorkoutTarget,
    required this.dailyStepTarget,
    required this.updatedAt,
  });

  /// Sensible defaults written once, right after onboarding.
  factory Goals.defaults() => Goals(
        dailyCalorieTarget: 400,
        weeklyCalorieTarget: 2500,
        dailyWorkoutTarget: 1,
        weeklyWorkoutTarget: 4,
        dailyStepTarget: StepConstants.defaultDailyStepGoal,
        updatedAt: DateTime.now(),
      );

  Goals copyWith({
    int? dailyCalorieTarget,
    int? weeklyCalorieTarget,
    int? dailyWorkoutTarget,
    int? weeklyWorkoutTarget,
    int? dailyStepTarget,
  }) {
    return Goals(
      dailyCalorieTarget: dailyCalorieTarget ?? this.dailyCalorieTarget,
      weeklyCalorieTarget: weeklyCalorieTarget ?? this.weeklyCalorieTarget,
      dailyWorkoutTarget: dailyWorkoutTarget ?? this.dailyWorkoutTarget,
      weeklyWorkoutTarget: weeklyWorkoutTarget ?? this.weeklyWorkoutTarget,
      dailyStepTarget: dailyStepTarget ?? this.dailyStepTarget,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, Object?> toMap() => {
        'daily_calorie_target': dailyCalorieTarget,
        'weekly_calorie_target': weeklyCalorieTarget,
        'daily_workout_target': dailyWorkoutTarget,
        'weekly_workout_target': weeklyWorkoutTarget,
        'daily_step_target': dailyStepTarget,
        'updated_at': updatedAt.toIso8601String(),
      };

  factory Goals.fromMap(Map<String, Object?> map) => Goals(
        dailyCalorieTarget: map['daily_calorie_target']! as int,
        weeklyCalorieTarget: map['weekly_calorie_target']! as int,
        dailyWorkoutTarget: map['daily_workout_target']! as int,
        weeklyWorkoutTarget: map['weekly_workout_target']! as int,
        dailyStepTarget: map['daily_step_target']! as int,
        updatedAt: DateTime.parse(map['updated_at']! as String),
      );
}

/// Today's and this week's progress toward [Goals], expressed as fractions
/// in `[0, 1]` (already clamped) so the UI can drive progress bars/rings
/// directly without re-deriving anything.
class GoalProgress {
  final double dailyCalorieFraction;
  final double weeklyCalorieFraction;
  final double dailyWorkoutFraction;
  final double weeklyWorkoutFraction;
  final double dailyStepFraction;

  const GoalProgress({
    required this.dailyCalorieFraction,
    required this.weeklyCalorieFraction,
    required this.dailyWorkoutFraction,
    required this.weeklyWorkoutFraction,
    required this.dailyStepFraction,
  });

  /// The single ring shown on the dashboard: the average of the two weekly
  /// fractions, representing overall progress toward this week's goals.
  double get weeklyOverallFraction =>
      ((weeklyCalorieFraction + weeklyWorkoutFraction) / 2).clamp(0.0, 1.0);
}
