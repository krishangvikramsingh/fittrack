import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/step_log.dart';
import '../utils/date_utils.dart';
import 'achievement_providers.dart';
import 'core_providers.dart';
import 'goal_providers.dart';

/// Turns the pedometer's raw (since-boot) sensor readings into "today's step
/// count", persisting progress after every reading so it survives an app
/// restart, and exposing the day's target from [goalsProvider] alongside it.
///
/// See [StepLog] for why a stored baseline is needed at all.
final stepCountProvider = StreamProvider<StepState>((ref) async* {
  final permissionService = ref.watch(permissionServiceProvider);
  final granted = await permissionService.requestActivityRecognition();
  if (!granted) {
    yield const StepCountPermissionDenied();
    return;
  }

  final stepRepo = ref.watch(stepRepositoryProvider);
  final pedometerService = ref.watch(pedometerServiceProvider);

  // Reacts to the user changing their daily step goal, but otherwise this
  // value only matters at stream-(re)start time.
  final dailyGoal = ref.watch(goalsProvider).valueOrNull?.dailyStepTarget ?? 8000;

  var todayKey = AppDateUtils.toDateKey(DateTime.now());
  var log = await stepRepo.getByDate(todayKey) ??
      StepLog(date: todayKey, steps: 0, sensorBaseline: -1, lastSensorValue: -1);

  try {
    await for (final sensorValue in pedometerService.stepCountStream()) {
      final currentKey = AppDateUtils.toDateKey(DateTime.now());
      final isNewDay = currentKey != todayKey;
      final isFirstReadingEver = log.sensorBaseline < 0;
      final sensorWasReset = sensorValue < log.lastSensorValue;

      if (isNewDay || isFirstReadingEver || sensorWasReset) {
        todayKey = currentKey;
        log = StepLog(
          date: todayKey,
          steps: 0,
          sensorBaseline: sensorValue,
          lastSensorValue: sensorValue,
        );
      } else {
        log = log.copyWith(
          steps: sensorValue - log.sensorBaseline,
          lastSensorValue: sensorValue,
        );
      }

      await stepRepo.upsert(log);
      yield StepCountAvailable(steps: log.steps, goal: dailyGoal);

      if (log.steps >= 10000) {
        // Fire-and-forget: an achievement-check failure shouldn't break the
        // step stream itself.
        unawaited(ref.read(achievementsProvider.notifier).evaluate());
      }
    }
  } catch (_) {
    yield const StepCountUnavailable();
  }
});
