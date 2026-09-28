import 'package:permission_handler/permission_handler.dart';

import '../utils/app_exception.dart';

/// Thin wrapper around `permission_handler` so the rest of the app depends on
/// a small typed API instead of the plugin directly, and every call is
/// guarded against platform-channel failures.
class PermissionService {
  Future<bool> requestActivityRecognition() => _request(Permission.activityRecognition);

  Future<bool> requestNotifications() => _request(Permission.notification);

  /// Android 12+ only; the plugin no-ops (and reports granted) on older
  /// versions where exact alarms don't require a separate permission.
  Future<bool> requestExactAlarm() => _request(Permission.scheduleExactAlarm);

  Future<bool> isActivityRecognitionGranted() => _isGranted(Permission.activityRecognition);

  Future<bool> _request(Permission permission) async {
    try {
      final status = await permission.request();
      return status.isGranted || status.isLimited;
    } catch (e) {
      throw AppException('Failed to request permission', e);
    }
  }

  Future<bool> _isGranted(Permission permission) async {
    try {
      final status = await permission.status;
      return status.isGranted || status.isLimited;
    } catch (e) {
      throw AppException('Failed to check permission status', e);
    }
  }
}
