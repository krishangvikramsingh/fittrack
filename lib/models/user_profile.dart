/// The user's fitness goal, chosen during onboarding and editable later.
enum FitnessGoal {
  lose,
  maintain,
  gain;

  String get label => switch (this) {
        FitnessGoal.lose => 'Lose weight',
        FitnessGoal.maintain => 'Maintain weight',
        FitnessGoal.gain => 'Gain weight',
      };

  static FitnessGoal fromName(String name) => FitnessGoal.values.firstWhere(
        (g) => g.name == name,
        orElse: () => FitnessGoal.maintain,
      );
}

enum Gender {
  male,
  female,
  other;

  String get label => switch (this) {
        Gender.male => 'Male',
        Gender.female => 'Female',
        Gender.other => 'Other',
      };

  static Gender fromName(String name) => Gender.values.firstWhere(
        (g) => g.name == name,
        orElse: () => Gender.other,
      );
}

/// The WHO weight-status category a BMI value falls into.
enum BmiCategory {
  underweight,
  normal,
  overweight,
  obese;

  String get label => switch (this) {
        BmiCategory.underweight => 'Underweight',
        BmiCategory.normal => 'Normal',
        BmiCategory.overweight => 'Overweight',
        BmiCategory.obese => 'Obese',
      };

  static BmiCategory fromName(String name) => BmiCategory.values.firstWhere(
        (c) => c.name == name,
        orElse: () => BmiCategory.normal,
      );
}

/// The single-row user profile: personal details plus the most recently
/// computed BMI. Weight/height are always stored in metric (kg/cm); unit
/// conversion for display happens only in the presentation layer.
class UserProfile {
  final String name;
  final int age;
  final double heightCm;
  final double weightKg;
  final Gender gender;
  final FitnessGoal goal;
  final double bmi;
  final BmiCategory bmiCategory;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.name,
    required this.age,
    required this.heightCm,
    required this.weightKg,
    required this.gender,
    required this.goal,
    required this.bmi,
    required this.bmiCategory,
    required this.createdAt,
    required this.updatedAt,
  });

  UserProfile copyWith({
    String? name,
    int? age,
    double? heightCm,
    double? weightKg,
    Gender? gender,
    FitnessGoal? goal,
    double? bmi,
    BmiCategory? bmiCategory,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      name: name ?? this.name,
      age: age ?? this.age,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      gender: gender ?? this.gender,
      goal: goal ?? this.goal,
      bmi: bmi ?? this.bmi,
      bmiCategory: bmiCategory ?? this.bmiCategory,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toMap() => {
        'name': name,
        'age': age,
        'height_cm': heightCm,
        'weight_kg': weightKg,
        'gender': gender.name,
        'goal': goal.name,
        'bmi': bmi,
        'bmi_category': bmiCategory.name,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory UserProfile.fromMap(Map<String, Object?> map) => UserProfile(
        name: map['name']! as String,
        age: map['age']! as int,
        heightCm: (map['height_cm']! as num).toDouble(),
        weightKg: (map['weight_kg']! as num).toDouble(),
        gender: Gender.fromName(map['gender']! as String),
        goal: FitnessGoal.fromName(map['goal']! as String),
        bmi: (map['bmi']! as num).toDouble(),
        bmiCategory: BmiCategory.fromName(map['bmi_category']! as String),
        createdAt: DateTime.parse(map['created_at']! as String),
        updatedAt: DateTime.parse(map['updated_at']! as String),
      );
}
