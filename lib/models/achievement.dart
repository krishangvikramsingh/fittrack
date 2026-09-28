import 'package:flutter/material.dart';

import '../utils/constants.dart';

/// Static definition of a badge: what it's called, how it's drawn, and its
/// unlock code. The *rule* for unlocking lives in `AchievementEvaluator`
/// (utils/achievement_evaluator.dart) - this class only describes the badge.
class AchievementDef {
  final String code;
  final String title;
  final String description;
  final IconData icon;

  const AchievementDef({
    required this.code,
    required this.title,
    required this.description,
    required this.icon,
  });
}

/// The full catalog of badges the app can award. Only *unlocked* badges are
/// persisted (in the `achievements` table); this list is the source of truth
/// for which badges exist and how they're displayed.
class AchievementCatalog {
  AchievementCatalog._();

  static const List<AchievementDef> all = [
    AchievementDef(
      code: AchievementCodes.firstWorkout,
      title: 'First Workout',
      description: 'Log your very first workout',
      icon: Icons.emoji_events,
    ),
    AchievementDef(
      code: AchievementCodes.workouts10,
      title: '10 Workouts Logged',
      description: 'Log 10 workouts in total',
      icon: Icons.fitness_center,
    ),
    AchievementDef(
      code: AchievementCodes.workouts50,
      title: '50 Workouts Logged',
      description: 'Log 50 workouts in total',
      icon: Icons.military_tech,
    ),
    AchievementDef(
      code: AchievementCodes.streak3,
      title: '3-Day Streak',
      description: 'Work out 3 days in a row',
      icon: Icons.local_fire_department,
    ),
    AchievementDef(
      code: AchievementCodes.streak7,
      title: '7-Day Streak',
      description: 'Work out 7 days in a row',
      icon: Icons.local_fire_department,
    ),
    AchievementDef(
      code: AchievementCodes.streak30,
      title: '30-Day Streak',
      description: 'Work out 30 days in a row',
      icon: Icons.local_fire_department,
    ),
    AchievementDef(
      code: AchievementCodes.calories5000,
      title: '5,000 kcal Burned',
      description: 'Burn 5,000 calories in total',
      icon: Icons.whatshot,
    ),
    AchievementDef(
      code: AchievementCodes.steps10k,
      title: '10k Steps in a Day',
      description: 'Walk 10,000 steps in a single day',
      icon: Icons.directions_walk,
    ),
  ];

  static AchievementDef byCode(String code) =>
      all.firstWhere((a) => a.code == code);
}

/// A badge paired with whether the current user has unlocked it (and when).
class AchievementStatus {
  final AchievementDef def;
  final DateTime? unlockedAt;

  const AchievementStatus({required this.def, this.unlockedAt});

  bool get isUnlocked => unlockedAt != null;
}
