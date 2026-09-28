import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/app_settings.dart';
import '../../../providers/settings_providers.dart';
import '../../../utils/constants.dart';

/// Toggle + window/interval controls for hydration reminder notifications.
class HydrationReminderTile extends ConsumerWidget {
  final AppSettings settings;

  const HydrationReminderTile({super.key, required this.settings});

  static String _formatHour(int hour) {
    final period = hour < 12 ? 'AM' : 'PM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour $period';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Hydration reminders'),
          subtitle: Text(
            'Every ${settings.hydrationIntervalHours}h, '
            '${_formatHour(settings.hydrationStartHour)}–${_formatHour(settings.hydrationEndHour)}',
          ),
          value: settings.hydrationEnabled,
          onChanged: (enabled) => ref.read(settingsProvider.notifier).setHydrationReminders(
                enabled: enabled,
                startHour: settings.hydrationStartHour,
                endHour: settings.hydrationEndHour,
                intervalHours: settings.hydrationIntervalHours,
              ),
        ),
        if (settings.hydrationEnabled)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: DropdownButtonFormField<int>(
              initialValue: settings.hydrationIntervalHours,
              decoration: const InputDecoration(labelText: 'Every (hours)'),
              items: const [1, 2, 3, 4]
                  .map((h) => DropdownMenuItem(value: h, child: Text('$h h')))
                  .toList(),
              onChanged: (h) {
                if (h == null) return;
                ref.read(settingsProvider.notifier).setHydrationReminders(
                      enabled: true,
                      startHour: settings.hydrationStartHour,
                      endHour: settings.hydrationEndHour,
                      intervalHours: h,
                    );
              },
            ),
          ),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }
}
