import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../providers/user_provider.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  int _step = 1;
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  String _gender = 'male';
  String _activity = 'moderate';
  String _goal = 'maintain';

  final List<Map<String, String>> _activities = [
    {'value': 'sedentary', 'label': '🛋️ Ít vận động', 'desc': 'Ngồi nhiều, ít tập'},
    {'value': 'light', 'label': '🚶 Nhẹ', 'desc': 'Tập 1-3 ngày/tuần'},
    {'value': 'moderate', 'label': '🏃 Vừa', 'desc': 'Tập 3-5 ngày/tuần'},
    {'value': 'active', 'label': '💪 Năng động', 'desc': 'Tập 6-7 ngày/tuần'},
    {'value': 'very_active', 'label': '🏋️ Rất năng động', 'desc': 'VĐV / lao động nặng'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_step < 4) {
      setState(() => _step++);
    } else {
      _saveProfile();
    }
  }

  void _saveProfile() {
    if (_nameController.text.isEmpty || _ageController.text.isEmpty || _weightController.text.isEmpty || _heightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')));
      return;
    }

    final profile = UserProfile(
      name: _nameController.text,
      age: int.parse(_ageController.text),
      gender: _gender,
      weightKg: double.parse(_weightController.text),
      heightCm: double.parse(_heightController.text),
      activityLevel: _activity,
      goal: _goal,
      hasCompletedSetup: true,
    );

    context.read<UserProvider>().updateProfile(profile);
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Thiết lập hồ sơ'), backgroundColor: Color(0xFF4CAF50), foregroundColor: Colors.white),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Bước $_step/4', style: TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Text(
              _step == 1 ? 'Bạn tên gì? 👋' : _step == 2 ? 'Thông tin cơ bản 📏' : _step == 3 ? 'Mức vận động 🏃' : 'Mục tiêu của bạn 🎯',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            Expanded(
              child: _buildStepContent(),
            ),
            Row(
              children: [
                if (_step > 1)
                  TextButton(onPressed: () => setState(() => _step--), child: Text('← Quay lại')),
                Spacer(),
                ElevatedButton(
                  onPressed: _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4CAF50),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(_step < 4 ? 'Tiếp →' : 'Hoàn thành ✨', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_step) {
      case 1:
        return TextField(
          controller: _nameController,
          decoration: InputDecoration(labelText: 'Tên của bạn', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          style: TextStyle(fontSize: 16),
        );
      case 2:
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: Text('👨 Nam'),
                    selected: _gender == 'male',
                    onSelected: (v) => setState(() => _gender = 'male'),
                    selectedColor: Color(0xFF4CAF50),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ChoiceChip(
                    label: Text('👩 Nữ'),
                    selected: _gender == 'female',
                    onSelected: (v) => setState(() => _gender = 'female'),
                    selectedColor: Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            TextField(controller: _ageController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Tuổi', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            SizedBox(height: 12),
            TextField(controller: _weightController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Cân nặng (kg)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            SizedBox(height: 12),
            TextField(controller: _heightController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Chiều cao (cm)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
          ],
        );
      case 3:
        return ListView(
          children: _activities.map((opt) {
            final isActive = _activity == opt['value'];
            return Card(
              color: isActive ? Color(0xFFE8F5E9) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isActive ? Color(0xFF4CAF50) : Colors.grey[300]!, width: 2)),
              child: ListTile(
                title: Text(opt['label']!, style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(opt['desc']!),
                onTap: () => setState(() => _activity = opt['value']!),
              ),
            );
          }).toList(),
        );
      case 4:
        return Column(
          children: [
            _GoalCard(active: _goal == 'lose', label: '📉 Giảm cân', desc: 'Giảm 0.5kg/tuần', onTap: () => setState(() => _goal = 'lose')),
            SizedBox(height: 12),
            _GoalCard(active: _goal == 'maintain', label: '⚖️ Duy trì', desc: 'Giữ cân nặng hiện tại', onTap: () => setState(() => _goal = 'maintain')),
            SizedBox(height: 12),
            _GoalCard(active: _goal == 'gain', label: '📈 Tăng cân', desc: 'Tăng cơ, tăng cân lành mạnh', onTap: () => setState(() => _goal = 'gain')),
          ],
        );
      default:
        return Container();
    }
  }
}

class _GoalCard extends StatelessWidget {
  final bool active;
  final String label;
  final String desc;
  final VoidCallback onTap;

  const _GoalCard({required this.active, required this.label, required this.desc, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: active ? Color(0xFFE8F5E9) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: active ? Color(0xFF4CAF50) : Colors.grey[300]!, width: 2)),
      child: ListTile(
        title: Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        subtitle: Text(desc),
        onTap: onTap,
      ),
    );
  }
}