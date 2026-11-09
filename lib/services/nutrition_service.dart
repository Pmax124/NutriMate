import '../models/user_profile.dart';
import '../models/nutrition_target.dart';

class NutritionService {
  static const Map<String, double> _activityMultiplier = {
    'sedentary': 1.2,
    'light': 1.375,
    'moderate': 1.55,
    'active': 1.725,
    'very_active': 1.9,
  };

  /// Công thức Mifflin-St Jeor - chuẩn vàng
  static double calculateBMR(UserProfile profile) {
    // Truy cập trực tiếp thuộc tính của profile
    if (profile.gender == 'male') {
      return 10 * profile.weightKg + 6.25 * profile.heightCm - 5 * profile.age + 5;
    }
    return 10 * profile.weightKg + 6.25 * profile.heightCm - 5 * profile.age - 161;
  }

  static int calculateTDEE(UserProfile profile) {
    final bmr = calculateBMR(profile);
    final multiplier = _activityMultiplier[profile.activityLevel] ?? 1.55;
    return (bmr * multiplier).round();
  }

  static NutritionTarget calculateTarget(UserProfile profile) {
    final tdee = calculateTDEE(profile);
    double calories = tdee.toDouble();

    if (profile.goal == 'lose') {
      calories = tdee - 500; // -500 kcal/ngày ≈ -0.5kg/tuần
    } else if (profile.goal == 'gain') {
      calories = tdee + 300;
    }

    // Macro split: 30% protein, 40% carb, 30% fat
    final protein = ((calories * 0.3) / 4).round();
    final carbs = ((calories * 0.4) / 4).round();
    final fat = ((calories * 0.3) / 9).round();
    final water = (profile.weightKg * 0.035 * 10).round() / 10;

    return NutritionTarget(
      calories: calories.round(),
      protein: protein,
      carbs: carbs,
      fat: fat,
      water: water,
    );
  }

  static double calculateBMI(double weightKg, double heightCm) {
    final heightM = heightCm / 100;
    return (weightKg / (heightM * heightM) * 10).round() / 10;
  }

  static String getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Thiếu cân';
    if (bmi < 25) return 'Bình thường';
    if (bmi < 30) return 'Thừa cân';
    return 'Béo phì';
  }
}