import 'package:flutter_test/flutter_test.dart';
import 'package:fittrack/models/user_profile.dart';
import 'package:fittrack/utils/bmi_calculator.dart';

void main() {
  group('BmiCalculator.calculate', () {
    test('computes standard BMI', () {
      // 70kg / (1.75m)^2 = 22.857...
      final bmi = BmiCalculator.calculate(weightKg: 70, heightCm: 175);
      expect(bmi, closeTo(22.857, 0.01));
    });

    test('returns 0 for zero height', () {
      expect(BmiCalculator.calculate(weightKg: 70, heightCm: 0), 0);
    });

    test('returns 0 for negative weight', () {
      expect(BmiCalculator.calculate(weightKg: -5, heightCm: 175), 0);
    });
  });

  group('BmiCalculator.categorize', () {
    test('boundary just below underweight max is underweight', () {
      expect(BmiCalculator.categorize(18.4), BmiCategory.underweight);
    });

    test('boundary at underweight max is normal', () {
      expect(BmiCalculator.categorize(18.5), BmiCategory.normal);
    });

    test('boundary just below normal max is normal', () {
      expect(BmiCalculator.categorize(24.9), BmiCategory.normal);
    });

    test('boundary at normal max is overweight', () {
      expect(BmiCalculator.categorize(25.0), BmiCategory.overweight);
    });

    test('boundary just below overweight max is overweight', () {
      expect(BmiCalculator.categorize(29.9), BmiCategory.overweight);
    });

    test('boundary at overweight max is obese', () {
      expect(BmiCalculator.categorize(30.0), BmiCategory.obese);
    });

    test('well above obese threshold is obese', () {
      expect(BmiCalculator.categorize(40.0), BmiCategory.obese);
    });
  });
}
