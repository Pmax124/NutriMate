class NutritionTarget {
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final double water; // lít

  NutritionTarget({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.water,
  });

  Map<String, dynamic> toJson() => {
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'water': water,
      };

  factory NutritionTarget.fromJson(Map<String, dynamic> json) =>
      NutritionTarget(
        calories: json['calories'] ?? 2000,
        protein: json['protein'] ?? 150,
        carbs: json['carbs'] ?? 200,
        fat: json['fat'] ?? 67,
        water: (json['water'] ?? 2.0).toDouble(),
      );
}