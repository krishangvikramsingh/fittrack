import 'package:flutter/material.dart';

import '../utils/constants.dart';

enum WeightUnit {
  kg,
  lb;

  String get label => this == WeightUnit.kg ? 'kg' : 'lb';
}

enum HeightUnit {
  cm,
  inch;

  String get label => this == HeightUnit.cm ? 'cm' : 'in';
}

/// App-wide preferences persisted in SharedPreferences (as opposed to the
/// sqflite tables, which hold the user's actual fitness data).
class AppSettings {
  /// Whether the onboarding flow has been completed. This - not "does a
  /// profile row exist" - is the single source of truth `app.dart` uses to
  /// decide between showing onboarding and the main shell, because the
  /// profile row is written partway *through* onboarding (before the weight
  /// log and goals are), so gating on it caused the app to swap screens out
  /// from under onboarding mid-flow.
  final bool onboardingComplete;

  final ThemeMode themeMode;
  final WeightUnit weightUnit;
  final HeightUnit heightUnit;

  final bool workoutReminderEnabled;
  final int workoutReminderHour;
  final int workoutReminderMinute;

  final bool hydrationEnabled;
  final int hydrationStartHour;
  final int hydrationEndHour;
  final int hydrationIntervalHours;

  const AppSettings({
    this.onboardingComplete = false,
    this.themeMode = ThemeMode.system,
    this.weightUnit = WeightUnit.kg,
    this.heightUnit = HeightUnit.cm,
    this.workoutReminderEnabled = false,
    this.workoutReminderHour = NotificationConstants.defaultWorkoutReminderHour,
    this.workoutReminderMinute =
        NotificationConstants.defaultWorkoutReminderMinute,
    this.hydrationEnabled = false,
    this.hydrationStartHour = NotificationConstants.defaultHydrationStartHour,
    this.hydrationEndHour = NotificationConstants.defaultHydrationEndHour,
    this.hydrationIntervalHours =
        NotificationConstants.defaultHydrationIntervalHours,
  });

  AppSettings copyWith({
    bool? onboardingComplete,
    ThemeMode? themeMode,
    WeightUnit? weightUnit,
    HeightUnit? heightUnit,
    bool? workoutReminderEnabled,
    int? workoutReminderHour,
    int? workoutReminderMinute,
    bool? hydrationEnabled,
    int? hydrationStartHour,
    int? hydrationEndHour,
    int? hydrationIntervalHours,
  }) {
    return AppSettings(
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      themeMode: themeMode ?? this.themeMode,
      weightUnit: weightUnit ?? this.weightUnit,
      heightUnit: heightUnit ?? this.heightUnit,
      workoutReminderEnabled:
          workoutReminderEnabled ?? this.workoutReminderEnabled,
      workoutReminderHour: workoutReminderHour ?? this.workoutReminderHour,
      workoutReminderMinute:
          workoutReminderMinute ?? this.workoutReminderMinute,
      hydrationEnabled: hydrationEnabled ?? this.hydrationEnabled,
      hydrationStartHour: hydrationStartHour ?? this.hydrationStartHour,
      hydrationEndHour: hydrationEndHour ?? this.hydrationEndHour,
      hydrationIntervalHours:
          hydrationIntervalHours ?? this.hydrationIntervalHours,
    );
  }
}
