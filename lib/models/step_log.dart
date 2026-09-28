/// One day's step-counter state.
///
/// The pedometer sensor reports a cumulative count *since the device booted*,
/// not since midnight, so we track [sensorBaseline] (the sensor's value the
/// first time we saw it "today") alongside [lastSensorValue] (used to detect
/// a reboot, which resets the sensor to a smaller number than we last saw).
/// [steps] = lastSensorValue - sensorBaseline, persisted so today's count
/// survives an app restart.
class StepLog {
  /// yyyy-MM-dd
  final String date;
  final int steps;
  final int sensorBaseline;
  final int lastSensorValue;

  const StepLog({
    required this.date,
    required this.steps,
    required this.sensorBaseline,
    required this.lastSensorValue,
  });

  StepLog copyWith({int? steps, int? sensorBaseline, int? lastSensorValue}) {
    return StepLog(
      date: date,
      steps: steps ?? this.steps,
      sensorBaseline: sensorBaseline ?? this.sensorBaseline,
      lastSensorValue: lastSensorValue ?? this.lastSensorValue,
    );
  }

  Map<String, Object?> toMap() => {
        'date': date,
        'steps': steps,
        'sensor_baseline': sensorBaseline,
        'last_sensor_value': lastSensorValue,
      };

  factory StepLog.fromMap(Map<String, Object?> map) => StepLog(
        date: map['date']! as String,
        steps: map['steps']! as int,
        sensorBaseline: map['sensor_baseline']! as int,
        lastSensorValue: map['last_sensor_value']! as int,
      );
}

/// Live state exposed by `stepCountProvider` to the dashboard.
sealed class StepState {
  const StepState();
}

class StepCountAvailable extends StepState {
  final int steps;
  final int goal;
  const StepCountAvailable({required this.steps, required this.goal});
}

/// The device has no step-count sensor (common on emulators), or the
/// pedometer stream errored out.
class StepCountUnavailable extends StepState {
  const StepCountUnavailable();
}

/// ACTIVITY_RECOGNITION permission hasn't been granted yet.
class StepCountPermissionDenied extends StepState {
  const StepCountPermissionDenied();
}
