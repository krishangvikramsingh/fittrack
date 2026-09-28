/// Converts between the metric units the app stores internally (kg, cm) and
/// the imperial units it can optionally display (lb, in). All persistence
/// stays metric; conversion happens only at the UI boundary.
class UnitConverter {
  UnitConverter._();

  static const double kgPerLb = 0.45359237;
  static const double cmPerInch = 2.54;

  static double kgToLb(double kg) => kg / kgPerLb;
  static double lbToKg(double lb) => lb * kgPerLb;

  static double cmToInch(double cm) => cm / cmPerInch;
  static double inchToCm(double inch) => inch * cmPerInch;
}
