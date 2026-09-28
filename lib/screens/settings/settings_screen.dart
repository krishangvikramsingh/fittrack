import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/app_settings.dart';
import '../../providers/achievement_providers.dart';
import '../../providers/core_providers.dart';
import '../../providers/goal_providers.dart';
import '../../providers/profile_providers.dart';
import '../../providers/settings_providers.dart';
import '../../providers/weight_providers.dart';
import '../../providers/workout_providers.dart';
import '../../utils/constants.dart';
import '../goals/goals_screen.dart';
import 'edit_profile_screen.dart';
import 'widgets/hydration_reminder_tile.dart';
import 'widgets/workout_reminder_tile.dart';

/// The Settings tab: profile shortcut, appearance, units, goals shortcut,
/// reminders, and a reset-data escape hatch.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmResetData(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset all data?'),
        content: const Text(
          'This permanently deletes your profile, workouts, weight history, '
          'goals and achievements from this device. This cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(dialogContext).colorScheme.error),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete everything'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final db = ref.read(databaseProvider);
    for (final table in [
      DbConstants.tableWorkouts,
      DbConstants.tableWeightLogs,
      DbConstants.tableGoals,
      DbConstants.tableAchievements,
      DbConstants.tableStepLogs,
      DbConstants.tableUserProfile,
    ]) {
      await db.delete(table);
    }
    await ref.read(sharedPreferencesProvider).clear();

    ref.invalidate(profileProvider);
    ref.invalidate(workoutsProvider);
    ref.invalidate(weightLogsProvider);
    ref.invalidate(goalsProvider);
    ref.invalidate(achievementsProvider);

    // Must be last: this flips app.dart's reactive gate back to
    // OnboardingScreen, which disposes this screen's element - nothing
    // below this line may touch `ref` or `context` again. No imperative
    // navigation needed on top of it (see onboarding_screen.dart's
    // completeOnboarding call for why running both caused a crash).
    ref.read(settingsProvider.notifier).resetToDefaults();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final profileAsync = ref.watch(profileProvider);
    final profile = profileAsync.valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          if (profile != null)
            Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(profile.name),
                subtitle: Text('${profile.goal.label} • BMI ${profile.bmi.toStringAsFixed(1)}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => EditProfileScreen(profile: profile)),
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          _SettingsSectionLabel('Appearance'),
          Card(
            child: SwitchListTile(
              title: const Text('Dark mode'),
              value: settings.themeMode == ThemeMode.dark,
              onChanged: (isDark) => ref
                  .read(settingsProvider.notifier)
                  .setThemeMode(isDark ? ThemeMode.dark : ThemeMode.light),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _SettingsSectionLabel('Units'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  _UnitRow(
                    label: 'Weight',
                    segments: const {WeightUnit.kg: 'kg', WeightUnit.lb: 'lb'},
                    selected: settings.weightUnit,
                    onChanged: (u) => ref.read(settingsProvider.notifier).setWeightUnit(u),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _UnitRow(
                    label: 'Height',
                    segments: const {HeightUnit.cm: 'cm', HeightUnit.inch: 'in'},
                    selected: settings.heightUnit,
                    onChanged: (u) => ref.read(settingsProvider.notifier).setHeightUnit(u),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _SettingsSectionLabel('Goals'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: const Text('Daily & weekly targets'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const GoalsScreen()),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _SettingsSectionLabel('Reminders'),
          Card(
            child: Column(
              children: [
                WorkoutReminderTile(settings: settings),
                const Divider(height: 1),
                HydrationReminderTile(settings: settings),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _SettingsSectionLabel('About'),
          const Card(
            child: ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('FitTrack'),
              subtitle: Text('Version 1.0.0'),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.delete_forever, color: Theme.of(context).colorScheme.error),
              title: Text('Reset all data', style: TextStyle(color: Theme.of(context).colorScheme.error)),
              onTap: () => _confirmResetData(context, ref),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSectionLabel extends StatelessWidget {
  final String text;
  const _SettingsSectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm, left: 4),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}

class _UnitRow<T> extends StatelessWidget {
  final String label;
  final Map<T, String> segments;
  final T selected;
  final ValueChanged<T> onChanged;

  const _UnitRow({
    required this.label,
    required this.segments,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        SegmentedButton<T>(
          segments: segments.entries
              .map((e) => ButtonSegment(value: e.key, label: Text(e.value)))
              .toList(),
          selected: {selected},
          showSelectedIcon: false,
          onSelectionChanged: (set) => onChanged(set.first),
        ),
      ],
    );
  }
}
