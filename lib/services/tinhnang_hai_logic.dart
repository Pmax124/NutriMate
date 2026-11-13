import 'dart:math';
import '../models/food_item.dart';
import '../models/user_profile.dart';
import 'food_database.dart';
import 'nutrition_service.dart';

// ===== Tính năng: Lịch trình tăng/giảm cân (Hai) =====

/// Một món trong bữa ăn của lịch trình
class ScheduleDish {
  final FoodItem food;
  final double servings; // số khẩu phần

  ScheduleDish({required this.food, required this.servings});

  double get calories => food.calories * servings;
  double get protein => food.protein * servings;
  double get carbs => food.carbs * servings;
  double get fat => food.fat * servings;
}

/// Một bữa (Sáng / Trưa / Tối / Phụ)
class ScheduleMeal {
  final String name;
  final String emoji;
  final double targetCalories;
  final List<ScheduleDish> dishes;

  ScheduleMeal({
    required this.name,
    required this.emoji,
    required this.targetCalories,
    required this.dishes,
  });

  double get totalCalories => dishes.fold(0.0, (s, d) => s + d.calories);
  double get totalProtein => dishes.fold(0.0, (s, d) => s + d.protein);
  double get totalCarbs => dishes.fold(0.0, (s, d) => s + d.carbs);
  double get totalFat => dishes.fold(0.0, (s, d) => s + d.fat);
}

/// Một ngày trong lịch trình
class ScheduleDay {
  final int dayNumber;
  final List<ScheduleMeal> meals;

  ScheduleDay({required this.dayNumber, required this.meals});

  double get totalCalories => meals.fold(0.0, (s, m) => s + m.totalCalories);
  double get totalProtein => meals.fold(0.0, (s, m) => s + m.totalProtein);
  double get totalCarbs => meals.fold(0.0, (s, m) => s + m.totalCarbs);
  double get totalFat => meals.fold(0.0, (s, m) => s + m.totalFat);
}

/// Toàn bộ lịch trình
class WeightSchedule {
  final String goal; // 'lose' hoặc 'gain'
  final int totalDays;
  final int tdee;
  final int dailyCalories;
  final bool limitedByMinimum; // true nếu calo bị nâng lên mức tối thiểu an toàn
  final double expectedChangeKg; // âm = giảm cân, dương = tăng cân
  final List<ScheduleDay> days;

  WeightSchedule({
    required this.goal,
    required this.totalDays,
    required this.tdee,
    required this.dailyCalories,
    required this.limitedByMinimum,
    required this.expectedChangeKg,
    required this.days,
  });
}

/// Kết quả tính calo mỗi ngày theo mục tiêu
class DailyPlan {
  final int tdee;
  final int calories;
  final bool limited;
  DailyPlan({required this.tdee, required this.calories, required this.limited});
}

class _MealTemplate {
  final String name;
  final String emoji;
  final double ratio; // tỉ lệ calo của bữa trong ngày
  final List<List<String>> scalable; // nhóm món được tăng/giảm khẩu phần
  final List<List<String>> fixed; // nhóm món cố định 1 khẩu phần
  final List<String> filler; // món bù thêm nếu còn thiếu calo

  const _MealTemplate({
    required this.name,
    required this.emoji,
    required this.ratio,
    required this.scalable,
    required this.fixed,
    required this.filler,
  });
}

class ScheduleService {
  static const double _kcalPerKg = 7700; // ~7700 kcal tương đương 1 kg
  static const int minDays = 3;
  static const int maxDays = 30;

  // Các id lấy từ FoodDatabase của nhóm
  static const List<_MealTemplate> _templates = [
    _MealTemplate(
      name: 'Bữa sáng',
      emoji: '🌅',
      ratio: 0.25,
      scalable: [
        ['4', '27', '31', '3', '7'], // phở bò, bánh mì ốp la, xôi, bánh mì, hủ tiếu
      ],
      fixed: [
        ['9', '22', '23'], // trứng, sữa tươi, sữa đậu nành
      ],
      filler: ['18', '19', '20', '22'],
    ),
    _MealTemplate(
      name: 'Bữa trưa',
      emoji: '☀️',
      ratio: 0.35,
      scalable: [
        ['1', '2'], // cơm trắng, cơm gạo lứt
        ['8', '10', '11', '13', '12'], // ức gà, cá hồi, thịt heo, tôm, đậu phụ
      ],
      fixed: [
        ['14', '17', '15', '16'], // rau củ
      ],
      filler: ['18', '19', '20', '21'],
    ),
    _MealTemplate(
      name: 'Bữa tối',
      emoji: '🌙',
      ratio: 0.30,
      scalable: [
        ['2', '1'],
        ['10', '13', '8', '12', '11'],
      ],
      fixed: [
        ['17', '14', '16', '15'],
      ],
      filler: ['19', '20', '21', '18'],
    ),
    _MealTemplate(
      name: 'Bữa phụ',
      emoji: '🍎',
      ratio: 0.10,
      scalable: [
        ['18', '19', '20', '21', '23', '22', '26'], // trái cây, sữa, nước dừa
      ],
      fixed: [],
      filler: [],
    ),
  ];

  /// Tính calo mỗi ngày theo mục tiêu (dùng cùng quy ước với NutritionService:
  /// giảm cân -500 kcal, tăng cân +300 kcal)
  static DailyPlan planDaily(UserProfile profile, String goal) {
    final tdee = NutritionService.calculateTDEE(profile);
    final bmr = NutritionService.calculateBMR(profile);
    int calories = tdee + (goal == 'gain' ? 300 : -500);
    bool limited = false;

    // Không cho calo thấp hơn BMR và tối thiểu 1200 kcal
    final minCalories = max(bmr.round(), 1200);
    if (calories < minCalories) {
      calories = minCalories;
      limited = true;
    }
    return DailyPlan(tdee: tdee, calories: calories, limited: limited);
  }

  /// Ước tính cân nặng thay đổi (kg) sau [days] ngày
  static double estimateChangeKg(DailyPlan plan, int days) {
    return (plan.calories - plan.tdee) * days / _kcalPerKg;
  }

  /// Tạo lịch trình
  static WeightSchedule generate({
    required UserProfile profile,
    required String goal,
    required int days,
  }) {
    final totalDays = days.clamp(minDays, maxDays).toInt();
    final plan = planDaily(profile, goal);

    final dayList = <ScheduleDay>[];
    for (int d = 1; d <= totalDays; d++) {
      final meals = <ScheduleMeal>[];
      for (int i = 0; i < _templates.length; i++) {
        meals.add(_buildMeal(_templates[i], i, d, plan.calories));
      }
      dayList.add(ScheduleDay(dayNumber: d, meals: meals));
    }

    return WeightSchedule(
      goal: goal,
      totalDays: totalDays,
      tdee: plan.tdee,
      dailyCalories: plan.calories,
      limitedByMinimum: plan.limited,
      expectedChangeKg: estimateChangeKg(plan, totalDays),
      days: dayList,
    );
  }

  static ScheduleMeal _buildMeal(_MealTemplate t, int mealIndex, int day, int dailyCalories) {
    final target = dailyCalories * t.ratio;
    final used = <String>{};

    final scalableFoods = <FoodItem>[];
    for (int k = 0; k < t.scalable.length; k++) {
      final f = _pick(t.scalable[k], day + k * 2 + mealIndex, used);
      if (f != null) scalableFoods.add(f);
    }

    final fixedFoods = <FoodItem>[];
    for (int k = 0; k < t.fixed.length; k++) {
      final f = _pick(t.fixed[k], day + k + mealIndex * 2, used);
      if (f != null) fixedFoods.add(f);
    }

    final fixedCal = fixedFoods.fold(0.0, (s, f) => s + f.calories);
    final baseCal = scalableFoods.fold(0.0, (s, f) => s + f.calories);

    // Hệ số khẩu phần để bữa ăn gần với calo mục tiêu
    double factor = baseCal > 0 ? (target - fixedCal) / baseCal : 1.0;
    factor = factor.clamp(0.5, 3.0).toDouble();
    factor = _roundTo(factor, 0.25);

    final dishes = <ScheduleDish>[];
    for (final f in scalableFoods) {
      dishes.add(ScheduleDish(food: f, servings: factor));
    }
    for (final f in fixedFoods) {
      dishes.add(ScheduleDish(food: f, servings: 1));
    }

    // Nếu còn thiếu nhiều calo thì thêm 1 món bù
    final current = dishes.fold(0.0, (s, d) => s + d.calories);
    final remainder = target - current;
    if (remainder >= 50 && t.filler.isNotEmpty) {
      final filler = _pick(t.filler, day * 3 + mealIndex, used);
      if (filler != null && filler.calories > 0) {
        final s = _roundTo(remainder / filler.calories, 0.5).clamp(0.0, 3.0).toDouble();
        if (s >= 0.5) {
          dishes.add(ScheduleDish(food: filler, servings: s));
        }
      }
    }

    return ScheduleMeal(
      name: t.name,
      emoji: t.emoji,
      targetCalories: target,
      dishes: dishes,
    );
  }

  /// Chọn 1 món trong nhóm, xoay vòng theo [seed] để mỗi ngày khác nhau
  static FoodItem? _pick(List<String> pool, int seed, Set<String> used) {
    for (int i = 0; i < pool.length; i++) {
      final id = pool[(seed + i) % pool.length];
      if (used.contains(id)) continue;
      final f = FoodDatabase.findById(id);
      if (f != null) {
        used.add(id);
        return f;
      }
    }
    return null;
  }

  static double _roundTo(double v, double step) => (v / step).round() * step;
}
