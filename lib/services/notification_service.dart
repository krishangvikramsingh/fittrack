import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../utils/app_exception.dart';
import '../utils/constants.dart';

/// Wraps `flutter_local_notifications` for the app's two reminder types:
/// a single daily workout reminder and a set of daily hydration reminders
/// spread across the user's waking hours.
///
/// Scheduling always uses the device's real IANA timezone (via
/// `flutter_timezone`) rather than guessing from the UTC offset, so a daily
/// reminder set for e.g. 6 PM keeps firing at 6 PM local time even across a
/// DST change.
///
/// Uses `timezone`'s `latest_all` data set (not `latest`): Android's
/// `TimeZone.getDefault().getID()` can return legacy zone names (e.g.
/// "Asia/Calcutta" instead of "Asia/Kolkata") that only `latest_all`
/// includes. With the smaller set, `tz.getLocation()` throws, which used to
/// get swallowed by the caller's try/catch, silently leaving `tz.local` on
/// its UTC default and firing every reminder shifted by the device's UTC
/// offset instead of at the configured local time.
class NotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    try {
      tz_data.initializeTimeZones();
      final localZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localZone.identifier));

      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      await _plugin.initialize(
        const InitializationSettings(android: androidSettings),
      );

      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          NotificationConstants.channelIdReminders,
          NotificationConstants.channelNameReminders,
          description: NotificationConstants.channelDescReminders,
        ),
      );

      _initialized = true;
    } catch (e) {
      throw AppException('Failed to initialize notifications', e);
    }
  }

  /// Requests POST_NOTIFICATIONS (Android 13+) and, separately, the ability
  /// to schedule *exact* alarms (Android 12+). Returns whether exact
  /// scheduling is available so the caller can fall back to an inexact
  /// (but still daily, still eventually-delivered) schedule mode.
  Future<bool> requestPermissionsAndCheckExactAlarms() async {
    try {
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();
      final exactAllowed = await androidPlugin?.requestExactAlarmsPermission();
      return exactAllowed ?? false;
    } catch (e) {
      throw AppException('Failed to request notification permissions', e);
    }
  }

  Future<void> scheduleWorkoutReminder({
    required int hour,
    required int minute,
    required bool exactAlarmsAllowed,
  }) async {
    try {
      await _plugin.zonedSchedule(
        NotificationConstants.workoutReminderId,
        'Time to work out 💪',
        "You haven't logged a workout today - keep the streak alive!",
        _nextInstanceOf(hour, minute),
        _details(),
        androidScheduleMode: exactAlarmsAllowed
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.wallClockTime,
      );
    } catch (e) {
      throw AppException('Failed to schedule workout reminder', e);
    }
  }

  Future<void> cancelWorkoutReminder() =>
      _plugin.cancel(NotificationConstants.workoutReminderId);

  /// Schedules one daily reminder per hour in `[startHour, endHour]`,
  /// stepping by [intervalHours], so hydration nudges only happen during
  /// waking hours instead of overnight.
  Future<void> scheduleHydrationReminders({
    required int startHour,
    required int endHour,
    required int intervalHours,
    required bool exactAlarmsAllowed,
  }) async {
    try {
      await cancelHydrationReminders();
      for (var hour = startHour; hour <= endHour; hour += intervalHours) {
        await _plugin.zonedSchedule(
          NotificationConstants.hydrationIdBase + hour,
          'Stay hydrated 💧',
          'Time for a glass of water.',
          _nextInstanceOf(hour, 0),
          _details(),
          androidScheduleMode: exactAlarmsAllowed
              ? AndroidScheduleMode.exactAllowWhileIdle
              : AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.wallClockTime,
        );
      }
    } catch (e) {
      throw AppException('Failed to schedule hydration reminders', e);
    }
  }

  Future<void> cancelHydrationReminders() async {
    for (var hour = 0; hour < 24; hour++) {
      await _plugin.cancel(NotificationConstants.hydrationIdBase + hour);
    }
  }

  NotificationDetails _details() => const NotificationDetails(
        android: AndroidNotificationDetails(
          NotificationConstants.channelIdReminders,
          NotificationConstants.channelNameReminders,
          channelDescription: NotificationConstants.channelDescReminders,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      );

  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
