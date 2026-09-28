import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';
import '../services/notification_service.dart';
import '../utils/constants.dart';
import 'core_providers.dart';

/// Holds [AppSettings], persisting every change to SharedPreferences and,
/// for the reminder-related fields, re-scheduling (or cancelling) the
/// corresponding local notifications so the two stay in sync.
class SettingsNotifier extends StateNotifier<AppSettings> {
  final SharedPreferences _prefs;
  final NotificationService _notificationService;

  SettingsNotifier(this._prefs, this._notificationService) : super(_loadInitial(_prefs));

  static AppSettings _loadInitial(SharedPreferences prefs) {
    final themeModeName = prefs.getString(PrefsKeys.themeMode);
    final themeMode = ThemeMode.values.firstWhere(
      (m) => m.name == themeModeName,
      orElse: () => ThemeMode.system,
    );
    final weightUnit = prefs.getString(PrefsKeys.weightUnit) == WeightUnit.lb.name
        ? WeightUnit.lb
        : WeightUnit.kg;
    final heightUnit = prefs.getString(PrefsKeys.heightUnit) == HeightUnit.inch.name
        ? HeightUnit.inch
        : HeightUnit.cm;

    return AppSettings(
      onboardingComplete: prefs.getBool(PrefsKeys.onboardingComplete) ?? false,
      themeMode: themeMode,
      weightUnit: weightUnit,
      heightUnit: heightUnit,
      workoutReminderEnabled: prefs.getBool(PrefsKeys.workoutReminderEnabled) ?? false,
      workoutReminderHour: prefs.getInt(PrefsKeys.workoutReminderHour) ??
          NotificationConstants.defaultWorkoutReminderHour,
      workoutReminderMinute: prefs.getInt(PrefsKeys.workoutReminderMinute) ??
          NotificationConstants.defaultWorkoutReminderMinute,
      hydrationEnabled: prefs.getBool(PrefsKeys.hydrationEnabled) ?? false,
      hydrationStartHour: prefs.getInt(PrefsKeys.hydrationStartHour) ??
          NotificationConstants.defaultHydrationStartHour,
      hydrationEndHour: prefs.getInt(PrefsKeys.hydrationEndHour) ??
          NotificationConstants.defaultHydrationEndHour,
      hydrationIntervalHours: prefs.getInt(PrefsKeys.hydrationIntervalHours) ??
          NotificationConstants.defaultHydrationIntervalHours,
    );
  }

  /// Marks onboarding as done. This is the single trigger `app.dart` uses
  /// to swap from `OnboardingScreen` to `ShellScreen` - called as the very
  /// last step of onboarding, after every other write it does, so that
  /// swap can't tear the onboarding screen down mid-flow.
  Future<void> completeOnboarding() async {
    state = state.copyWith(onboardingComplete: true);
    await _prefs.setBool(PrefsKeys.onboardingComplete, true);
  }

  /// Restores every setting to its default, in memory. Called after a
  /// "reset all data" wipe, which already clears the persisted copies via
  /// `SharedPreferences.clear()` - this just syncs the live state (which
  /// clearing storage alone doesn't touch) back to match, including
  /// flipping [AppSettings.onboardingComplete] back to false so `app.dart`
  /// reactively returns to onboarding.
  void resetToDefaults() {
    state = const AppSettings();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _prefs.setString(PrefsKeys.themeMode, mode.name);
  }

  Future<void> setWeightUnit(WeightUnit unit) async {
    state = state.copyWith(weightUnit: unit);
    await _prefs.setString(PrefsKeys.weightUnit, unit.name);
  }

  Future<void> setHeightUnit(HeightUnit unit) async {
    state = state.copyWith(heightUnit: unit);
    await _prefs.setString(PrefsKeys.heightUnit, unit.name);
  }

  Future<void> setWorkoutReminder({
    required bool enabled,
    int? hour,
    int? minute,
  }) async {
    state = state.copyWith(
      workoutReminderEnabled: enabled,
      workoutReminderHour: hour,
      workoutReminderMinute: minute,
    );
    await _prefs.setBool(PrefsKeys.workoutReminderEnabled, state.workoutReminderEnabled);
    await _prefs.setInt(PrefsKeys.workoutReminderHour, state.workoutReminderHour);
    await _prefs.setInt(PrefsKeys.workoutReminderMinute, state.workoutReminderMinute);

    if (state.workoutReminderEnabled) {
      final exactAllowed = await _notificationService.requestPermissionsAndCheckExactAlarms();
      await _notificationService.scheduleWorkoutReminder(
        hour: state.workoutReminderHour,
        minute: state.workoutReminderMinute,
        exactAlarmsAllowed: exactAllowed,
      );
    } else {
      await _notificationService.cancelWorkoutReminder();
    }
  }

  Future<void> setHydrationReminders({
    required bool enabled,
    int? startHour,
    int? endHour,
    int? intervalHours,
  }) async {
    state = state.copyWith(
      hydrationEnabled: enabled,
      hydrationStartHour: startHour,
      hydrationEndHour: endHour,
      hydrationIntervalHours: intervalHours,
    );
    await _prefs.setBool(PrefsKeys.hydrationEnabled, state.hydrationEnabled);
    await _prefs.setInt(PrefsKeys.hydrationStartHour, state.hydrationStartHour);
    await _prefs.setInt(PrefsKeys.hydrationEndHour, state.hydrationEndHour);
    await _prefs.setInt(PrefsKeys.hydrationIntervalHours, state.hydrationIntervalHours);

    if (state.hydrationEnabled) {
      final exactAllowed = await _notificationService.requestPermissionsAndCheckExactAlarms();
      await _notificationService.scheduleHydrationReminders(
        startHour: state.hydrationStartHour,
        endHour: state.hydrationEndHour,
        intervalHours: state.hydrationIntervalHours,
        exactAlarmsAllowed: exactAllowed,
      );
    } else {
      await _notificationService.cancelHydrationReminders();
    }
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier(
    ref.watch(sharedPreferencesProvider),
    ref.watch(notificationServiceProvider),
  );
});
