import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  final VoidCallback onStart;

  const OnboardingScreen({super.key, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Spacer(),
                Text('🥗', textAlign: TextAlign.center, style: TextStyle(fontSize: 80)),
                SizedBox(height: 20),
                Text(
                  'NutriMate',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 10),
                Text(
                  'Người bạn đồng hành\ndinh dưỡng của bạn',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.white.withOpacity(0.9)),
                ),
                SizedBox(height: 40),
                _Feature(icon: '📊', text: 'Theo dõi calo & macro thông minh'),
                _Feature(icon: '📷', text: 'Chụp ảnh món ăn - AI tính calo'),
                _Feature(icon: '🤖', text: 'Trợ lý dinh dưỡng AI 24/7'),
                _Feature(icon: '🍽️', text: 'Gợi ý thực đơn cá nhân hóa'),
                Spacer(),
                ElevatedButton(
                  onPressed: onStart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Color(0xFF2E7D32),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                  child: Text('Bắt đầu ngay', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  final String icon;
  final String text;

  const _Feature({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Text(icon, style: TextStyle(fontSize: 28)),
          SizedBox(width: 14),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}