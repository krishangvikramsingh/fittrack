/// A typed error wrapper used across repositories and services so callers
/// (providers) can rely on a single exception shape instead of catching
/// sqflite/platform-channel-specific exception types individually.
class AppException implements Exception {
  final String message;
  final Object? cause;

  const AppException(this.message, [this.cause]);

  @override
  String toString() => cause == null ? message : '$message ($cause)';
}
