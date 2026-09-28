/// Central home for every "magic number" and static string used across the
/// app: DB config, BMI thresholds, MET values, notification ids/timing,
/// achievement thresholds and shared UI spacing/animation constants.
///
/// Keeping these in one file means a reviewer (or a future contributor) can
/// tune the app's behaviour without hunting through widget code, and it
/// avoids the same literal being duplicated - and drifting - in multiple
/// places.
library;

// ---------------------------------------------------------------------------
// Database
// ---------------------------------------------------------------------------

class DbConstants {
  DbConstants._();

  static const String dbName = 'fittrack.db';
  static const int dbVersion = 1;

  static const String tableUserProfile = 'user_profile';
  static const String tableWorkouts = 'workouts';
  static const String tableWeightLogs = 'weight_logs';
  static const String tableGoals = 'goals';
  static const String tableAchievements = 'achievements';
  static const String tableStepLogs = 'step_logs';

  /// Singleton row id used for the one-row `user_profile` and `goals` tables.
  static const int singletonRowId = 1;
}

// ---------------------------------------------------------------------------
// SharedPreferences keys
// ---------------------------------------------------------------------------

class PrefsKeys {
  PrefsKeys._();

  static const String onboardingComplete = 'onboarding_complete';
  static const String themeMode = 'theme_mode';
  static const String weightUnit = 'weight_unit';
  static const String heightUnit = 'height_unit';

  static const String workoutReminderEnabled = 'workout_reminder_enabled';
  static const String workoutReminderHour = 'workout_reminder_hour';
  static const String workoutReminderMinute = 'workout_reminder_minute';

  static const String hydrationEnabled = 'hydration_enabled';
  static const String hydrationStartHour = 'hydration_start_hour';
  static const String hydrationEndHour = 'hydration_end_hour';
  static const String hydrationIntervalHours = 'hydration_interval_hours';
}

// ---------------------------------------------------------------------------
// BMI
// ---------------------------------------------------------------------------

class BmiConstants {
  BmiConstants._();

  static const double underweightMax = 18.5;
  static const double normalMax = 25.0;
  static const double overweightMax = 30.0;
}

// ---------------------------------------------------------------------------
// Calorie estimation (MET formula)
// ---------------------------------------------------------------------------

class CalorieConstants {
  CalorieConstants._();

  /// calories = MET * 3.5 * weightKg / 200 * minutes
  static const double metFormulaConstant = 3.5;
  static const double metFormulaDivisor = 200.0;
}

// ---------------------------------------------------------------------------
// Notifications
// ---------------------------------------------------------------------------

class NotificationConstants {
  NotificationConstants._();

  static const String channelIdReminders = 'fittrack_reminders';
  static const String channelNameReminders = 'Reminders';
  static const String channelDescReminders =
      'Workout and hydration reminders';

  static const int workoutReminderId = 1;

  /// Hydration reminders use ids in [hydrationIdBase, hydrationIdBase + 23]
  /// (one per possible hour of the day), so each scheduled time keeps a
  /// stable, collision-free id it can be cancelled/rescheduled by.
  static const int hydrationIdBase = 100;

  static const int defaultWorkoutReminderHour = 18;
  static const int defaultWorkoutReminderMinute = 0;
  static const int defaultHydrationStartHour = 8;
  static const int defaultHydrationEndHour = 20;
  static const int defaultHydrationIntervalHours = 2;
}

// ---------------------------------------------------------------------------
// Achievements
// ---------------------------------------------------------------------------

class AchievementCodes {
  AchievementCodes._();

  static const String firstWorkout = 'first_workout';
  static const String workouts10 = 'workouts_10';
  static const String workouts50 = 'workouts_50';
  static const String streak3 = 'streak_3';
  static const String streak7 = 'streak_7';
  static const String streak30 = 'streak_30';
  static const String calories5000 = 'calories_5000';
  static const String steps10k = 'steps_10k';
}

// ---------------------------------------------------------------------------
// UI spacing & animation
// ---------------------------------------------------------------------------

class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;

  static const double cardRadius = 16;
  static const double chipRadius = 12;
}

class AppDurations {
  AppDurations._();

  static const Duration progressRing = Duration(milliseconds: 900);
  static const Duration snackBar = Duration(seconds: 4);
  static const Duration fadeIn = Duration(milliseconds: 300);
}

// ---------------------------------------------------------------------------
// Step counter
// ---------------------------------------------------------------------------

class StepConstants {
  StepConstants._();

  static const int defaultDailyStepGoal = 8000;
}
