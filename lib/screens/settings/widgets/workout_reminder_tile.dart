import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/app_settings.dart';
import '../../../providers/settings_providers.dart';

/// Toggle + time picker for the daily workout reminder notification.
class WorkoutReminderTile extends ConsumerWidget {
  final AppSettings settings;

  const WorkoutReminderTile({super.key, required this.settings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final time = TimeOfDay(hour: settings.workoutReminderHour, minute: settings.workoutReminderMinute);

    return Column(
      children: [
        SwitchListTile(
          title: const Text('Workout reminder'),
          subtitle: const Text('A daily nudge if you haven\'t logged a workout'),
          value: settings.workoutReminderEnabled,
          onChanged: (enabled) => ref.read(settingsProvider.notifier).setWorkoutReminder(
                enabled: enabled,
                hour: settings.workoutReminderHour,
                minute: settings.workoutReminderMinute,
              ),
        ),
        if (settings.workoutReminderEnabled)
          ListTile(
            title: const Text('Reminder time'),
            trailing: Text(time.format(context)),
            onTap: () async {
              final picked = await showTimePicker(context: context, initialTime: time);
              if (picked != null) {
                await ref.read(settingsProvider.notifier).setWorkoutReminder(
                      enabled: true,
                      hour: picked.hour,
                      minute: picked.minute,
                    );
              }
            },
          ),
      ],
    );
  }
}
