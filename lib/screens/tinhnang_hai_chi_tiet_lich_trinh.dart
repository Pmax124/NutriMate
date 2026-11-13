import 'package:flutter/material.dart';
import '../services/tinhnang_hai_logic.dart';

/// Màn hình Chi tiết lịch trình: tổng quan + danh sách từng ngày (4 bữa)
class ChiTietLichTrinhScreen extends StatelessWidget {
  final WeightSchedule schedule;

  const ChiTietLichTrinhScreen({super.key, required this.schedule});

  String _fmtServings(double s) => s == s.roundToDouble() ? s.toInt().toString() : s.toString();

  @override
  Widget build(BuildContext context) {
    final isGain = schedule.goal == 'gain';
    final color = isGain ? const Color(0xFFFF9800) : const Color(0xFF4CAF50);
    final changeText = schedule.expectedChangeKg < 0 ? 'giảm' : 'tăng';

    return Scaffold(
      appBar: AppBar(title: const Text('Lịch trình của bạn')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Tổng quan
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${isGain ? '📈 Tăng cân' : '📉 Giảm cân'} trong ${schedule.totalDays} ngày',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
                  ),
                  const SizedBox(height: 12),
                  Text('Mục tiêu: ${schedule.dailyCalories} kcal/ngày', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('TDEE của bạn: ${schedule.tdee} kcal/ngày'),
                  const SizedBox(height: 4),
                  Text('Dự kiến $changeText khoảng ${schedule.expectedChangeKg.abs().toStringAsFixed(1)} kg (ước tính)'),
                  if (schedule.limitedByMinimum) ...[
                    const SizedBox(height: 4),
                    Text('Calo được giữ ở mức tối thiểu an toàn.', style: TextStyle(color: Colors.orange[800], fontSize: 12)),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          const Text('Danh sách từng ngày', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Bấm vào từng ngày để xem chi tiết món ăn', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          const SizedBox(height: 12),

          ...schedule.days.map((day) => _buildDay(day, color)),

          const SizedBox(height: 12),
          Text(
            'Lịch trình mang tính tham khảo, không thay thế tư vấn của chuyên gia dinh dưỡng hoặc bác sĩ.',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildDay(ScheduleDay day, Color color) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: ExpansionTile(
          shape: const Border(),
          collapsedShape: const Border(),
          leading: CircleAvatar(
            backgroundColor: color,
            child: Text('${day.dayNumber}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          title: Text('Ngày ${day.dayNumber}', style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(
            '${day.totalCalories.round()} kcal · P ${day.totalProtein.round()}g · C ${day.totalCarbs.round()}g · F ${day.totalFat.round()}g',
            style: const TextStyle(fontSize: 12),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          children: day.meals.map((m) => _buildMeal(m, color)).toList(),
        ),
      ),
    );
  }

  Widget _buildMeal(ScheduleMeal meal, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${meal.emoji} ${meal.name}', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
            Text('${meal.totalCalories.round()} kcal', style: TextStyle(color: Colors.grey[700], fontSize: 12)),
          ],
        ),
        const Divider(height: 12),
        ...meal.dishes.map(
          (d) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                Text(d.food.emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d.food.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text('${_fmtServings(d.servings)} × ${d.food.servingSize}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ),
                Text('${d.calories.round()} kcal', style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
