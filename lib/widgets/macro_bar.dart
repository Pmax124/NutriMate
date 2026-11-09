import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class MacroBar extends StatelessWidget {
  final String label;
  final double current;
  final double target;
  final Color color;
  final String unit;

  const MacroBar({
    super.key,
    required this.label,
    required this.current,
    required this.target,
    required this.color,
    this.unit = 'g',
  });

  @override
  Widget build(BuildContext context) {
    final percent = (current / target).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              Text(
                '${current.round()}$unit / ${target.round()}$unit',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ],
          ),
          SizedBox(height: 6),
          LinearPercentIndicator(
            percent: percent,
            backgroundColor: Colors.grey[200],
            progressColor: color,
            lineHeight: 10,
            barRadius: Radius.circular(5),
            animation: true,
            animationDuration: 800,
          ),
        ],
      ),
    );
  }
}