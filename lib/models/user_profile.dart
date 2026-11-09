class UserProfile {
  final String name;
  final int age;
  final String gender; // 'male' hoặc 'female'
  final double weightKg;
  final double heightCm;
  final String activityLevel; // sedentary, light, moderate, active, very_active
  final String goal; // lose, maintain, gain
  final bool hasCompletedSetup;

  UserProfile({
    required this.name,
    required this.age,
    required this.gender,
    required this.weightKg,
    required this.heightCm,
    required this.activityLevel,
    required this.goal,
    this.hasCompletedSetup = false,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'age': age,
        'gender': gender,
        'weightKg': weightKg,
        'heightCm': heightCm,
        'activityLevel': activityLevel,
        'goal': goal,
        'hasCompletedSetup': hasCompletedSetup,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        name: json['name'] ?? '',
        age: json['age'] ?? 25,
        gender: json['gender'] ?? 'male',
        weightKg: (json['weightKg'] ?? 60).toDouble(),
        heightCm: (json['heightCm'] ?? 170).toDouble(),
        activityLevel: json['activityLevel'] ?? 'moderate',
        goal: json['goal'] ?? 'maintain',
        hasCompletedSetup: json['hasCompletedSetup'] ?? false,
      );
}