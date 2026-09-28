import 'constants.dart';

/// Pure calorie-burn math using the standard MET formula:
///
///   calories = MET * 3.5 * weightKg / 200 * minutes
///
/// This is the same formula used by most fitness trackers to estimate energy
/// expenditure from a MET (Metabolic Equivalent of Task) score.
class CalorieCalculator {
  CalorieCalculator._();

  static double estimate({
    required double met,
    required double weightKg,
    required int durationMin,
  }) {
    if (met <= 0 || weightKg <= 0 || durationMin <= 0) return 0;
    return met *
        CalorieConstants.metFormulaConstant *
        weightKg /
        CalorieConstants.metFormulaDivisor *
        durationMin;
  }
}
