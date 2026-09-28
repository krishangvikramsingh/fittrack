import 'package:flutter_test/flutter_test.dart';
import 'package:fittrack/utils/streak_calculator.dart';

void main() {
  final now = DateTime(2026, 9, 28, 14, 30); // a Monday afternoon, fixed "today"

  group('StreakCalculator.compute', () {
    test('empty list gives zero streak', () {
      final info = StreakCalculator.compute([], now: now);
      expect(info.currentStreak, 0);
      expect(info.longestStreak, 0);
    });

    test('workout today only gives a streak of 1', () {
      final info = StreakCalculator.compute([now], now: now);
      expect(info.currentStreak, 1);
      expect(info.longestStreak, 1);
    });

    test('duplicate timestamps on the same day only count once', () {
      final timestamps = [
        DateTime(2026, 9, 28, 7, 0),
        DateTime(2026, 9, 28, 19, 0),
        DateTime(2026, 9, 28, 19, 30),
      ];
      final info = StreakCalculator.compute(timestamps, now: now);
      expect(info.currentStreak, 1);
      expect(info.longestStreak, 1);
    });

    test('consecutive days up to and including today', () {
      final timestamps = [
        DateTime(2026, 9, 26),
        DateTime(2026, 9, 27),
        DateTime(2026, 9, 28, 8),
      ];
      final info = StreakCalculator.compute(timestamps, now: now);
      expect(info.currentStreak, 3);
      expect(info.longestStreak, 3);
    });

    test('no workout logged yet today still counts yesterday\'s streak', () {
      // Nothing on the 28th (today) yet, but 26th and 27th are consecutive.
      final timestamps = [DateTime(2026, 9, 26), DateTime(2026, 9, 27)];
      final info = StreakCalculator.compute(timestamps, now: now);
      expect(info.currentStreak, 2);
    });

    test('a gap of more than a day breaks the current streak', () {
      // Last workout was 3 days ago - too old to count as "yesterday".
      final timestamps = [DateTime(2026, 9, 24), DateTime(2026, 9, 25)];
      final info = StreakCalculator.compute(timestamps, now: now);
      expect(info.currentStreak, 0);
      expect(info.longestStreak, 2);
    });

    test('longest streak can exceed the current streak', () {
      final timestamps = [
        DateTime(2026, 9, 10),
        DateTime(2026, 9, 11),
        DateTime(2026, 9, 12),
        DateTime(2026, 9, 13),
        DateTime(2026, 9, 14),
        // gap
        DateTime(2026, 9, 28), // today - streak of 1
      ];
      final info = StreakCalculator.compute(timestamps, now: now);
      expect(info.currentStreak, 1);
      expect(info.longestStreak, 5);
    });
  });
}
