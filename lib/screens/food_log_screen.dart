import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/food_log.dart';
import '../models/food_item.dart';
import '../providers/food_provider.dart';
import '../services/food_database.dart';
import '../widgets/food_card.dart';

class FoodLogScreen extends StatefulWidget {
  const FoodLogScreen({super.key});

  @override
  State<FoodLogScreen> createState() => _FoodLogScreenState();
}

class _FoodLogScreenState extends State<FoodLogScreen> {
  String _searchQuery = '';
  List<FoodItem> _searchResults = [];

  @override
  Widget build(BuildContext context) {
    final foodProvider = context.watch<FoodProvider>();
    final todayLogs = foodProvider.logs.where((l) {
      final today = DateTime.now();
      return l.timestamp.year == today.year && l.timestamp.month == today.month && l.timestamp.day == today.day;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text('Ghi chép bữa ăn'), backgroundColor: Color(0xFF4CAF50), foregroundColor: Colors.white),
      body: Column(
        children: [
          // Search
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              onChanged: (q) {
                setState(() {
                  _searchQuery = q;
                  _searchResults = FoodDatabase.search(q);
                });
              },
              decoration: InputDecoration(
                hintText: 'Tìm kiếm món ăn...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),

          // Today's logs
          if (todayLogs.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Hôm nay', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('${foodProvider.todayCalories.round()} kcal', style: TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          if (todayLogs.isNotEmpty)
            Expanded(
              flex: 1,
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: todayLogs.length,
                itemBuilder: (context, idx) {
                  final log = todayLogs[idx];
                  return Dismissible(
                    key: Key(log.id),
                    direction: DismissDirection.endToStart,
                    background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: EdgeInsets.only(right: 16), child: Icon(Icons.delete, color: Colors.white)),
                    onDismissed: (_) => foodProvider.removeFoodLog(log.id),
                    child: ListTile(
                      leading: Text(log.food.emoji, style: TextStyle(fontSize: 32)),
                      title: Text(log.food.name),
                      subtitle: Text('${log.quantity.toInt()}x • ${log.mealType}'),
                      trailing: Text('${log.totalCalories.round()} kcal', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4CAF50))),
                    ),
                  );
                },
              ),
            ),

          // Search results
          if (_searchQuery.isNotEmpty)
            Expanded(
              flex: 2,
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: _searchResults.length,
                itemBuilder: (context, idx) {
                  final food = _searchResults[idx];
                  return FoodCard(
                    food: food,
                    onTap: () => _showAddDialog(food),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void _showAddDialog(FoodItem food) {
    final qtyController = TextEditingController(text: '1');
    String mealType = 'snack';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Thêm ${food.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Số phần ăn'),
            ),
            SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: mealType,
              decoration: InputDecoration(labelText: 'Bữa ăn'),
              items: [
                DropdownMenuItem(value: 'breakfast', child: Text('🌅 Bữa sáng')),
                DropdownMenuItem(value: 'lunch', child: Text('☀️ Bữa trưa')),
                DropdownMenuItem(value: 'dinner', child: Text('🌙 Bữa tối')),
                DropdownMenuItem(value: 'snack', child: Text('🍎 Ăn vặt')),
              ],
              onChanged: (v) => mealType = v!,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              final qty = double.tryParse(qtyController.text) ?? 1;
              final log = FoodLog(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                food: food,
                quantity: qty,
                mealType: mealType,
                timestamp: DateTime.now(),
              );
              context.read<FoodProvider>().addFoodLog(log);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã thêm ${food.name}')));
            },
            child: Text('Thêm'),
          ),
        ],
      ),
    );
  }
}