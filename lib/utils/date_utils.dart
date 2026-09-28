import 'package:intl/intl.dart';

/// Small date helpers shared across repositories and widgets, so the same
/// "start of day" / "yyyy-MM-dd" logic isn't reimplemented in several places.
class AppDateUtils {
  AppDateUtils._();

  static final DateFormat isoDateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat dayMonthFormat = DateFormat('d MMM');
  static final DateFormat dayMonthYearFormat = DateFormat('d MMM yyyy');
  static final DateFormat weekdayShortFormat = DateFormat('EEE');
  static final DateFormat timeFormat = DateFormat('h:mm a');

  static DateTime startOfDay(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  static DateTime endOfDay(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day, 23, 59, 59, 999);

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// The Monday..Sunday range containing [dt].
  static (DateTime start, DateTime end) weekRange(DateTime dt) {
    final start = startOfDay(dt.subtract(Duration(days: dt.weekday - 1)));
    final end = endOfDay(start.add(const Duration(days: 6)));
    return (start, end);
  }

  static String toDateKey(DateTime dt) => isoDateFormat.format(dt);
}
