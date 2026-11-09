class FoodItem {
  final String id;
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final String servingSize;
  final String emoji;

  FoodItem({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.servingSize,
    this.emoji = '🍽️',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'servingSize': servingSize,
        'emoji': emoji,
      };

  factory FoodItem.fromJson(Map<String, dynamic> json) => FoodItem(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        calories: (json['calories'] ?? 0).toDouble(),
        protein: (json['protein'] ?? 0).toDouble(),
        carbs: (json['carbs'] ?? 0).toDouble(),
        fat: (json['fat'] ?? 0).toDouble(),
        servingSize: json['servingSize'] ?? '',
        emoji: json['emoji'] ?? '🍽️',
      );
}