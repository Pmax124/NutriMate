import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/tinhnang_hai_logic.dart';
import 'tinhnang_hai_chi_tiet_lich_trinh.dart';

/// Màn hình Tạo lịch trình: chọn mục tiêu + số ngày (3-30)
class TaoLichTrinhScreen extends StatefulWidget {
  const TaoLichTrinhScreen({super.key});

  @override
  State<TaoLichTrinhScreen> createState() => _TaoLichTrinhScreenState();
}

class _TaoLichTrinhScreenState extends State<TaoLichTrinhScreen> {
  String _goal = 'lose';
  double _days = 7;
  bool _loading = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final profile = context.read<UserProvider>().profile;
      if (profile != null && profile.goal == 'gain') _goal = 'gain';
      _initialized = true;
    }
  }

  Future<void> _createSchedule() async {
    final profile = context.read<UserProvider>().profile;
    if (profile == null) return;

    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1500)); // loading 1.5s

    final schedule = ScheduleService.generate(
      profile: profile,
      goal: _goal,
      days: _days.round(),
    );

    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChiTietLichTrinhScreen(schedule: schedule)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProvider>().profile;

    return Scaffold(
      appBar: AppBar(title: const Text('Tạo lịch trình')),
      body: profile == null
          ? const Center(child: Text('Chưa có hồ sơ người dùng'))
          : _loading
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Đang tính toán lịch trình...'),
                    ],
                  ),
                )
              : _buildForm(profile),
    );
  }

  Widget _buildForm(profile) {
    final plan = ScheduleService.planDaily(profile, _goal);
    final days = _days.round();
    final changeKg = ScheduleService.estimateChangeKg(plan, days);
    final changeText = changeKg < 0 ? 'giảm' : 'tăng';

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Thông tin hiện tại
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Thông tin của bạn', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text('Cân nặng hiện tại: ${profile.weightKg} kg'),
                const SizedBox(height: 4),
                Text('Năng lượng tiêu hao mỗi ngày (TDEE): ${plan.tdee} kcal'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Chọn mục tiêu
        const Text('Chọn mục tiêu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _GoalCard(
                emoji: '📉',
                title: 'Giảm cân',
                subtitle: 'Giảm ~0,5 kg/tuần',
                color: const Color(0xFF4CAF50),
                selected: _goal == 'lose',
                onTap: () => setState(() => _goal = 'lose'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _GoalCard(
                emoji: '📈',
                title: 'Tăng cân',
                subtitle: 'Tăng cân lành mạnh',
                color: const Color(0xFFFF9800),
                selected: _goal == 'gain',
                onTap: () => setState(() => _goal = 'gain'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Chọn số ngày
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Thời gian', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('$days ngày', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50))),
          ],
        ),
        Slider(
          value: _days,
          min: ScheduleService.minDays.toDouble(),
          max: ScheduleService.maxDays.toDouble(),
          divisions: ScheduleService.maxDays - ScheduleService.minDays,
          label: '$days ngày',
          onChanged: (v) => setState(() => _days = v),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${ScheduleService.minDays} ngày', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            Text('${ScheduleService.maxDays} ngày', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
        const SizedBox(height: 16),

        // Xem trước
        Card(
          elevation: 0,
          color: const Color(0xFF4CAF50).withOpacity(0.1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mục tiêu mỗi ngày: ${plan.calories} kcal', style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('Dự kiến $changeText khoảng ${changeKg.abs().toStringAsFixed(1)} kg sau $days ngày (ước tính)'),
                if (plan.limited) ...[
                  const SizedBox(height: 4),
                  Text('Calo đã được giữ ở mức tối thiểu an toàn.', style: TextStyle(color: Colors.orange[800], fontSize: 12)),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _createSchedule,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Tạo lịch trình ngay', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}

class _GoalCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _GoalCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.15) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? color : Colors.grey.shade300, width: 2),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: selected ? color : Colors.black87)),
            const SizedBox(height: 4),
            Text(subtitle, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}
