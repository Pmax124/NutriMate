import 'package:flutter/material.dart';
import '../models/food_item.dart';

class FoodCard extends StatelessWidget {
  final FoodItem food;
  final VoidCallback onTap;

  const FoodCard({
    super.key,
    required this.food,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: EdgeInsets.all(14),
          child: Row(
            children: [
              Text(food.emoji, style: TextStyle(fontSize: 36)),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(food.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    SizedBox(height: 2),
                    Text(food.servingSize, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Text('${food.calories.round()} kcal', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.green)),
                        SizedBox(width: 8),
                        Text('P:${food.protein}g • C:${food.carbs}g • F:${food.fat}g', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}