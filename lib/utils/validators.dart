/// Shared form-field validators, kept out of widget code so screens stay
/// focused on layout.
class Validators {
  Validators._();

  static String? requiredText(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }

  static String? positiveInt(String? value, {String fieldName = 'Value'}) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    final n = int.tryParse(value);
    if (n == null || n <= 0) return '$fieldName must be a positive number';
    return null;
  }

  static String? positiveDouble(String? value, {String fieldName = 'Value'}) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    final n = double.tryParse(value);
    if (n == null || n <= 0) return '$fieldName must be a positive number';
    return null;
  }

  static String? ageRange(String? value, {int min = 10, int max = 100}) {
    if (value == null || value.trim().isEmpty) return 'Age is required';
    final n = int.tryParse(value);
    if (n == null) return 'Age must be a number';
    if (n < min || n > max) return 'Age must be between $min and $max';
    return null;
  }
}
