import 'package:flutter_test/flutter_test.dart';
import 'package:fittrack/utils/calorie_calculator.dart';

void main() {
  group('CalorieCalculator.estimate', () {
    test('computes calories via the MET formula', () {
      // MET 9.8 (running), 70kg, 30 min:
      // 9.8 * 3.5 * 70 / 200 * 30 = 360.15
      final cal = CalorieCalculator.estimate(met: 9.8, weightKg: 70, durationMin: 30);
      expect(cal, closeTo(360.15, 0.01));
    });

    test('returns 0 for zero duration', () {
      expect(CalorieCalculator.estimate(met: 9.8, weightKg: 70, durationMin: 0), 0);
    });

    test('returns 0 for zero MET', () {
      expect(CalorieCalculator.estimate(met: 0, weightKg: 70, durationMin: 30), 0);
    });

    test('returns 0 for negative weight', () {
      expect(CalorieCalculator.estimate(met: 9.8, weightKg: -70, durationMin: 30), 0);
    });

    test('scales linearly with duration', () {
      final a = CalorieCalculator.estimate(met: 5.0, weightKg: 60, durationMin: 10);
      final b = CalorieCalculator.estimate(met: 5.0, weightKg: 60, durationMin: 20);
      expect(b, closeTo(a * 2, 0.0001));
    });
  });
}
