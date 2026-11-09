import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/ai_service.dart';

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key});

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  String? _mealPlan;
  bool _isLoading = false;

  Future<void> _generatePlan() async {
    setState(() {
      _isLoading = true;
      _mealPlan = null;
    });

    final profile = context.read<UserProvider>().profile;
    final plan = await AIService.suggestMealPlan(profile);

    setState(() {
      _mealPlan = plan;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Thực đơn AI'), backgroundColor: Color(0xFFFF9800), foregroundColor: Colors.white),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text('🍽️ Thực đơn cá nhân hóa', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('AI sẽ gợi ý thực đơn phù hợp với mục tiêu của bạn', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _generatePlan,
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFFF9800), padding: EdgeInsets.symmetric(vertical: 16)),
                child: Text(_isLoading ? 'Đang tạo...' : '✨ Tạo thực đơn với AI', style: TextStyle(fontSize: 16)),
              ),
            ),
            SizedBox(height: 20),
            if (_isLoading) Expanded(child: Center(child: CircularProgressIndicator())),
            if (_mealPlan != null)
              Expanded(
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: SingleChildScrollView(
                      child: Text(_mealPlan!, style: TextStyle(fontSize: 15, height: 1.6)),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}