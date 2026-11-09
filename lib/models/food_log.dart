import 'food_item.dart';

class FoodLog {
  final String id;
  final FoodItem food;
  final double quantity; // số phần ăn
  final String mealType; // breakfast, lunch, dinner, snack
  final DateTime timestamp;

  FoodLog({
    required this.id,
    required this.food,
    required this.quantity,
    required this.mealType,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'food': food.toJson(),
        'quantity': quantity,
        'mealType': mealType,
        'timestamp': timestamp.toIso8601String(),
      };

  factory FoodLog.fromJson(Map<String, dynamic> json) => FoodLog(
        id: json['id'] ?? '',
        food: FoodItem.fromJson(json['food']),
        quantity: (json['quantity'] ?? 1).toDouble(),
        mealType: json['mealType'] ?? 'snack',
        timestamp: DateTime.parse(json['timestamp']),
      );

  double get totalCalories => food.calories * quantity;
  double get totalProtein => food.protein * quantity;
  double get totalCarbs => food.carbs * quantity;
  double get totalFat => food.fat * quantity;
}