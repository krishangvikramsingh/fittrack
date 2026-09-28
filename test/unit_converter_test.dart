import 'package:flutter_test/flutter_test.dart';
import 'package:fittrack/utils/unit_converter.dart';

void main() {
  group('UnitConverter', () {
    test('kg <-> lb round-trip', () {
      const kg = 70.0;
      final lb = UnitConverter.kgToLb(kg);
      expect(lb, closeTo(154.32, 0.01));
      expect(UnitConverter.lbToKg(lb), closeTo(kg, 0.0001));
    });

    test('cm <-> inch round-trip', () {
      const cm = 175.0;
      final inch = UnitConverter.cmToInch(cm);
      expect(inch, closeTo(68.9, 0.1));
      expect(UnitConverter.inchToCm(inch), closeTo(cm, 0.0001));
    });
  });
}
