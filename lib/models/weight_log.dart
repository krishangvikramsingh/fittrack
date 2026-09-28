/// A single weight measurement, with the BMI computed at that point in time.
/// Drives both the weight-trend chart and the BMI-history chart.
class WeightLog {
  final String id;
  final double weightKg;
  final double bmi;
  final DateTime loggedAt;

  const WeightLog({
    required this.id,
    required this.weightKg,
    required this.bmi,
    required this.loggedAt,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'weight_kg': weightKg,
        'bmi': bmi,
        'logged_at': loggedAt.toIso8601String(),
      };

  factory WeightLog.fromMap(Map<String, Object?> map) => WeightLog(
        id: map['id']! as String,
        weightKg: (map['weight_kg']! as num).toDouble(),
        bmi: (map['bmi']! as num).toDouble(),
        loggedAt: DateTime.parse(map['logged_at']! as String),
      );
}
