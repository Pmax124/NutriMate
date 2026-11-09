import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class CalorieCircle extends StatelessWidget {
  final double current;
  final double target;

  const CalorieCircle({
    super.key,
    required this.current,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (current / target).clamp(0.0, 1.0);
    final remaining = target - current;
    final isOver = current > target;

    return CircularPercentIndicator(
      radius: 110.0,
      lineWidth: 18.0,
      percent: progress,
      center: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${current.round()}',
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.bold,
              color: isOver ? Colors.red : Colors.green,
            ),
          ),
          Text(
            '/ ${target.round()} kcal',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          SizedBox(height: 4),
          Text(
            isOver ? 'Dư ${remaining.abs().round()}' : 'Còn ${remaining.round()}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isOver ? Colors.red : Colors.green,
            ),
          ),
        ],
      ),
      progressColor: isOver ? Colors.red : Colors.green,
      backgroundColor: Colors.grey[200]!,
      circularStrokeCap: CircularStrokeCap.round,
      animation: true,
      animationDuration: 1000,
    );
  }
}