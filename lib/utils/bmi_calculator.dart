import '../models/user_profile.dart';
import 'constants.dart';

/// Pure BMI math: no I/O, no Flutter imports, fully unit-testable.
class BmiCalculator {
  BmiCalculator._();

  /// BMI = weight(kg) / height(m)^2.
  ///
  /// Returns 0 for non-positive height, which callers should treat as "not
  /// computable" rather than a real BMI value.
  static double calculate({required double weightKg, required double heightCm}) {
    if (heightCm <= 0 || weightKg <= 0) return 0;
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  /// WHO weight-status bands.
  static BmiCategory categorize(double bmi) {
    if (bmi < BmiConstants.underweightMax) return BmiCategory.underweight;
    if (bmi < BmiConstants.normalMax) return BmiCategory.normal;
    if (bmi < BmiConstants.overweightMax) return BmiCategory.overweight;
    return BmiCategory.obese;
  }
}
