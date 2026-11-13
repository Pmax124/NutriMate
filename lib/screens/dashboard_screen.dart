import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/food_provider.dart';
import '../widgets/calorie_circle.dart';
import '../widgets/macro_bar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<FoodProvider>().loadAll();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final foodProvider = context.watch<FoodProvider>();
    final profile = userProvider.profile;
    final target = userProvider.target;

    if (profile == null || target == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final waterTargetGlasses = (target.water * 1000 / 250).round();
    final waterGlasses = foodProvider.todayWaterGlasses;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => foodProvider.loadAll(),
        child: ListView(
          padding: EdgeInsets.all(20),
          children: [
            SizedBox(height: 30),
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Xin chào, ${profile.name} 👋', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('Hôm nay bạn cần ${target.calories} kcal', style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Color(0xFF4CAF50),
                  child: Text('👤', style: TextStyle(fontSize: 24)),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Calorie Circle
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CalorieCircle(current: foodProvider.todayCalories, target: target.calories.toDouble()),
              ),
            ),
            SizedBox(height: 20),

            // Macros
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Macronutrients', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 16),
                    MacroBar(label: 'Protein', current: foodProvider.todayProtein, target: target.protein.toDouble(), color: Colors.orange),
                    MacroBar(label: 'Carbs', current: foodProvider.todayCarbs, target: target.carbs.toDouble(), color: Colors.blue),
                    MacroBar(label: 'Fat', current: foodProvider.todayFat, target: target.fat.toDouble(), color: Colors.pink),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Water
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('💧 Nước uống', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('$waterGlasses / $waterTargetGlasses ly', style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                    SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: List.generate(waterTargetGlasses, (i) {
                        return Text(i < waterGlasses ? '💧' : '○', style: TextStyle(fontSize: 24));
                      }),
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => foodProvider.addWater(),
                        icon: Icon(Icons.add),
                        label: Text('Thêm 1 ly (250ml)'),
                        style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF2196F3), padding: EdgeInsets.symmetric(vertical: 12)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Quick Actions
            Row(
              children: [
                _ActionBtn(icon: '🍽️', label: 'Ghi bữa ăn', color: Color(0xFF4CAF50), onTap: () => Navigator.pushNamed(context, '/foodLog')),
                _ActionBtn(icon: '📷', label: 'Quét món', color: Color(0xFF2196F3), onTap: () => Navigator.pushNamed(context, '/scanFood')),
                _ActionBtn(icon: '🤖', label: 'Hỏi AI', color: Color(0xFF9C27B0), onTap: () => Navigator.pushNamed(context, '/chatAI')),
                _ActionBtn(icon: '📅', label: 'Thực đơn', color: Color(0xFFFF9800), onTap: () => Navigator.pushNamed(context, '/mealPlan')),
              ],
            ),
            SizedBox(height: 20),

            // Weight tracker button
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: ListTile(
                leading: Icon(Icons.monitor_weight, color: Color(0xFF4CAF50), size: 32),
                title: Text('Theo dõi cân nặng', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('Xem biểu đồ cân nặng của bạn'),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () => Navigator.pushNamed(context, '/weightTracker'),
              ),
            ),
            SizedBox(height: 20),

            // Nút Lịch trình (Hai)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: ListTile(
                leading: Icon(Icons.event_note, color: Color(0xFFFF9800), size: 32),
                title: Text('Lịch trình', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('Lên lịch tăng/giảm cân theo số ngày'),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () => Navigator.pushNamed(context, '/schedule'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 4),
          padding: EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text(icon, style: TextStyle(fontSize: 28)),
              SizedBox(height: 6),
              Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}