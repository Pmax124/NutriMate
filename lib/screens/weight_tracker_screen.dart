import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/food_provider.dart';

class WeightTrackerScreen extends StatefulWidget {
  const WeightTrackerScreen({super.key});

  @override
  State<WeightTrackerScreen> createState() => _WeightTrackerScreenState();
}

class _WeightTrackerScreenState extends State<WeightTrackerScreen> {
  final _weightController = TextEditingController();

  void _addWeight() {
    final weight = double.tryParse(_weightController.text);
    if (weight == null || weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Nhập cân nặng hợp lệ')));
      return;
    }

    context.read<FoodProvider>().addWeight(weight);
    _weightController.clear();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã ghi nhận $weight kg')));
  }

  @override
  Widget build(BuildContext context) {
    final weightLogs = context.watch<FoodProvider>().weightLogs;

    return Scaffold(
      appBar: AppBar(title: Text('Theo dõi cân nặng'), backgroundColor: Color(0xFF4CAF50), foregroundColor: Colors.white),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Cân nặng (kg)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                ),
                SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _addWeight,
                  style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF4CAF50), padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                  child: Text('Thêm'),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Chart
            if (weightLogs.length >= 2)
              Expanded(
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: true, drawVerticalLine: false),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: weightLogs.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.weight)).toList(),
                            isCurved: true,
                            color: Color(0xFF4CAF50),
                            barWidth: 4,
                            dotData: FlDotData(show: true),
                            belowBarData: BarAreaData(show: true, color: Color(0xFF4CAF50).withOpacity(0.2)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('⚖️', style: TextStyle(fontSize: 80)),
                      SizedBox(height: 16),
                      Text('Chưa có dữ liệu', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                      Text('Hãy thêm cân nặng đầu tiên!', style: TextStyle(color: Colors.grey[500])),
                    ],
                  ),
                ),
              ),

            // History
            if (weightLogs.isNotEmpty)
              Container(
                height: 150,
                child: ListView.builder(
                  itemCount: weightLogs.length,
                  itemBuilder: (context, idx) {
                    final entry = weightLogs[idx];
                    return ListTile(
                      leading: CircleAvatar(child: Text('${idx + 1}')),
                      title: Text('${entry.weight} kg'),
                      subtitle: Text('${entry.timestamp.day}/${entry.timestamp.month}/${entry.timestamp.year}'),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}