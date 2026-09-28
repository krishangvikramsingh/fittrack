import 'package:pedometer/pedometer.dart';

/// Thin wrapper around the `pedometer` plugin's step-count stream.
///
/// The sensor reports a value that is cumulative *since the device booted*
/// (not since midnight), so this service just forwards raw sensor readings;
/// `stepCountProvider` is responsible for turning them into "today's steps"
/// using a stored baseline (see models/step_log.dart for why).
class PedometerService {
  /// Emits the sensor's cumulative step count on every step. The stream
  /// errors out (rather than emitting) if the device has no step sensor,
  /// which the caller should treat as [StepCountUnavailable].
  Stream<int> stepCountStream() {
    return Pedometer.stepCountStream.map((event) => event.steps);
  }
}
