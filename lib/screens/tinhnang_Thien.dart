// ignore_for_file: file_names
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/user_provider.dart';
import '../services/nutrition_service.dart';

// ==========================================
// MODELS: LỊCH TRÌNH TĂNG GIẢM CÂN (THIỆN)
// ==========================================

class ScheduleDish {
  final String name;
  final String portion;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final String emoji;

  ScheduleDish({
    required this.name,
    required this.portion,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.emoji = '🍽️',
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'portion': portion,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'emoji': emoji,
      };

  factory ScheduleDish.fromJson(Map<String, dynamic> json) => ScheduleDish(
        name: json['name'] ?? '',
        portion: json['portion'] ?? '',
        calories: (json['calories'] ?? 0).toDouble(),
        protein: (json['protein'] ?? 0).toDouble(),
        carbs: (json['carbs'] ?? 0).toDouble(),
        fat: (json['fat'] ?? 0).toDouble(),
        emoji: json['emoji'] ?? '🍽️',
      );
}

class ScheduleMeal {
  final String type; // breakfast, lunch, dinner, snack
  final String name; // Bữa Sáng, Bữa Trưa, Bữa Tối, Bữa Phụ
  final String time;
  final String icon;
  final List<ScheduleDish> dishes;

  ScheduleMeal({
    required this.type,
    required this.name,
    required this.time,
    required this.icon,
    required this.dishes,
  });

  double get totalCalories => dishes.fold(0, (sum, d) => sum + d.calories);
  double get totalProtein => dishes.fold(0, (sum, d) => sum + d.protein);
  double get totalCarbs => dishes.fold(0, (sum, d) => sum + d.carbs);
  double get totalFat => dishes.fold(0, (sum, d) => sum + d.fat);

  Map<String, dynamic> toJson() => {
        'type': type,
        'name': name,
        'time': time,
        'icon': icon,
        'dishes': dishes.map((d) => d.toJson()).toList(),
      };

  factory ScheduleMeal.fromJson(Map<String, dynamic> json) => ScheduleMeal(
        type: json['type'] ?? '',
        name: json['name'] ?? '',
        time: json['time'] ?? '',
        icon: json['icon'] ?? '🍽️',
        dishes: (json['dishes'] as List? ?? [])
            .map((e) => ScheduleDish.fromJson(e))
            .toList(),
      );
}

class ScheduleDay {
  final int dayNumber;
  final String title;
  final List<ScheduleMeal> meals;

  ScheduleDay({
    required this.dayNumber,
    required this.title,
    required this.meals,
  });

  double get totalCalories => meals.fold(0, (sum, m) => sum + m.totalCalories);
  double get totalProtein => meals.fold(0, (sum, m) => sum + m.totalProtein);
  double get totalCarbs => meals.fold(0, (sum, m) => sum + m.totalCarbs);
  double get totalFat => meals.fold(0, (sum, m) => sum + m.totalFat);

  Map<String, dynamic> toJson() => {
        'dayNumber': dayNumber,
        'title': title,
        'meals': meals.map((m) => m.toJson()).toList(),
      };

  factory ScheduleDay.fromJson(Map<String, dynamic> json) => ScheduleDay(
        dayNumber: json['dayNumber'] ?? 1,
        title: json['title'] ?? 'Ngày 1',
        meals: (json['meals'] as List? ?? [])
            .map((e) => ScheduleMeal.fromJson(e))
            .toList(),
      );
}

class MealPlanSchedule {
  final String id;
  final String goal; // 'lose' hoặc 'gain'
  final int durationDays;
  final int dailyCalorieTarget;
  final int dailyProtein;
  final int dailyCarbs;
  final int dailyFat;
  final DateTime createdAt;
  final List<ScheduleDay> days;

  MealPlanSchedule({
    required this.id,
    required this.goal,
    required this.durationDays,
    required this.dailyCalorieTarget,
    required this.dailyProtein,
    required this.dailyCarbs,
    required this.dailyFat,
    required this.createdAt,
    required this.days,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'goal': goal,
        'durationDays': durationDays,
        'dailyCalorieTarget': dailyCalorieTarget,
        'dailyProtein': dailyProtein,
        'dailyCarbs': dailyCarbs,
        'dailyFat': dailyFat,
        'createdAt': createdAt.toIso8601String(),
        'days': days.map((d) => d.toJson()).toList(),
      };

  factory MealPlanSchedule.fromJson(Map<String, dynamic> json) =>
      MealPlanSchedule(
        id: json['id'] ?? '',
        goal: json['goal'] ?? 'lose',
        durationDays: json['durationDays'] ?? 7,
        dailyCalorieTarget: json['dailyCalorieTarget'] ?? 1800,
        dailyProtein: json['dailyProtein'] ?? 135,
        dailyCarbs: json['dailyCarbs'] ?? 180,
        dailyFat: json['dailyFat'] ?? 60,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.now(),
        days: (json['days'] as List? ?? [])
            .map((e) => ScheduleDay.fromJson(e))
            .toList(),
      );
}

// ==========================================
// GENERATOR ENGINE (TẠO THỰC ĐƠN ĐA DẠNG)
// ==========================================

class ScheduleGenerator {
  static final List<List<ScheduleDish>> _breakfastLoss = [
    [
      ScheduleDish(name: 'Phở bò tái nạc', portion: '1 tô nhỏ', calories: 350, protein: 26, carbs: 45, fat: 7, emoji: '🍜'),
      ScheduleDish(name: 'Trà xanh ấm không đường', portion: '1 tách', calories: 2, protein: 0, carbs: 0.5, fat: 0, emoji: '🍵'),
    ],
    [
      ScheduleDish(name: 'Bánh mì ngũ cốc ốp la 2 trứng', portion: '1 phần', calories: 330, protein: 18, carbs: 32, fat: 12, emoji: '🥪'),
      ScheduleDish(name: 'Dưa chuột thái lát', portion: '100g', calories: 15, protein: 0.7, carbs: 3.6, fat: 0.1, emoji: '🥒'),
    ],
    [
      ScheduleDish(name: 'Yến mạch nấu sữa đậu nành & táo', portion: '1 bát', calories: 310, protein: 14, carbs: 50, fat: 5, emoji: '🥣'),
      ScheduleDish(name: 'Hạt chia ngâm', portion: '1 muỗng cà phê', calories: 40, protein: 2, carbs: 3, fat: 2.5, emoji: '🌱'),
    ],
    [
      ScheduleDish(name: 'Hủ tiếu gà xé nạc', portion: '1 tô vừa', calories: 340, protein: 24, carbs: 46, fat: 6, emoji: '🍜'),
      ScheduleDish(name: 'Rau thơm & giá đỗ', portion: '1 đĩa nhỏ', calories: 15, protein: 1.5, carbs: 2, fat: 0.1, emoji: '🥬'),
    ],
    [
      ScheduleDish(name: 'Khoai lang luộc', portion: '1 củ vừa (150g)', calories: 130, protein: 2, carbs: 30, fat: 0.2, emoji: '🍠'),
      ScheduleDish(name: 'Trứng gà luộc lòng đào', portion: '2 quả', calories: 156, protein: 13, carbs: 1.2, fat: 10, emoji: '🥚'),
      ScheduleDish(name: 'Cà phê đen không đường', portion: '1 ly', calories: 2, protein: 0.3, carbs: 0, fat: 0, emoji: '☕'),
    ],
  ];

  static final List<List<ScheduleDish>> _breakfastGain = [
    [
      ScheduleDish(name: 'Phở bò nạm gầu đặc biệt', portion: '1 tô lớn', calories: 550, protein: 35, carbs: 65, fat: 18, emoji: '🍜'),
      ScheduleDish(name: 'Trứng trần', portion: '1 quả', calories: 78, protein: 6, carbs: 0.6, fat: 5, emoji: '🥚'),
      ScheduleDish(name: 'Sữa tươi tiệt trùng nguyên kem', portion: '1 ly 200ml', calories: 130, protein: 7, carbs: 10, fat: 7, emoji: '🥛'),
    ],
    [
      ScheduleDish(name: 'Xôi gà xé nấm thịt kho', portion: '1 phần đầy', calories: 520, protein: 25, carbs: 70, fat: 16, emoji: '🍚'),
      ScheduleDish(name: 'Sữa đậu nành mè đen', portion: '1 ly', calories: 120, protein: 7, carbs: 12, fat: 4.5, emoji: '🥛'),
    ],
    [
      ScheduleDish(name: 'Bánh mì pate trứng xúc xích', portion: '1 ổ lớn', calories: 580, protein: 24, carbs: 60, fat: 26, emoji: '🥖'),
      ScheduleDish(name: 'Sữa chua dầm chuối chín', portion: '1 bát', calories: 160, protein: 6, carbs: 30, fat: 2.5, emoji: '🍌'),
    ],
    [
      ScheduleDish(name: 'Bún bò Huế thập cẩm', portion: '1 tô đặc biệt', calories: 560, protein: 34, carbs: 65, fat: 19, emoji: '🍜'),
      ScheduleDish(name: 'Chả lụa thêm', portion: '50g', calories: 115, protein: 8, carbs: 3, fat: 8, emoji: '🥩'),
    ],
  ];

  static final List<List<ScheduleDish>> _lunchLoss = [
    [
      ScheduleDish(name: 'Cơm gạo lứt huyết rồng', portion: '1 chén (120g)', calories: 132, protein: 3, carbs: 28, fat: 0.9, emoji: '🍚'),
      ScheduleDish(name: 'Ức gà áp chảo sốt tiêu đen', portion: '150g', calories: 245, protein: 46, carbs: 2, fat: 5.5, emoji: '🍗'),
      ScheduleDish(name: 'Bông cải xanh hấp', portion: '150g', calories: 50, protein: 4.2, carbs: 10, fat: 0.6, emoji: '🥦'),
      ScheduleDish(name: 'Canh bí đao thịt nạc', portion: '1 bát nhỏ', calories: 45, protein: 4, carbs: 5, fat: 1, emoji: '🍲'),
    ],
    [
      ScheduleDish(name: 'Cơm gạo lứt', portion: '1 chén (100g)', calories: 110, protein: 2.5, carbs: 23, fat: 0.8, emoji: '🍚'),
      ScheduleDish(name: 'Cá hồi nướng muối tiêu chanh', portion: '130g', calories: 270, protein: 26, carbs: 0, fat: 17, emoji: '🐟'),
      ScheduleDish(name: 'Măng tây & cà chua bi xào dầu olive', portion: '150g', calories: 65, protein: 3, carbs: 8, fat: 2.5, emoji: '🍅'),
      ScheduleDish(name: 'Canh cải ngọt nấu tôm băm', portion: '1 bát', calories: 40, protein: 5, carbs: 4, fat: 0.5, emoji: '🍲'),
    ],
    [
      ScheduleDish(name: 'Bún gạo lứt trộn thịt heo luộc nạc', portion: '1 tô', calories: 380, protein: 28, carbs: 48, fat: 8, emoji: '🍜'),
      ScheduleDish(name: 'Rau xà lách & dưa leo sốt chanh tươi', portion: '1 đĩa', calories: 35, protein: 1.5, carbs: 6, fat: 0.5, emoji: '🥗'),
    ],
    [
      ScheduleDish(name: 'Cơm trắng', portion: '3/4 chén (80g)', calories: 104, protein: 2.1, carbs: 22.4, fat: 0.2, emoji: '🍚'),
      ScheduleDish(name: 'Tôm rim tỏi ớt ít dầu', portion: '120g', calories: 140, protein: 28, carbs: 2, fat: 2, emoji: '🦐'),
      ScheduleDish(name: 'Đậu phụ hấp sả', portion: '80g', calories: 60, protein: 6.5, carbs: 1.5, fat: 3.5, emoji: '🧈'),
      ScheduleDish(name: 'Canh rau ngót nấu thịt nạc băm', portion: '1 bát', calories: 60, protein: 7, carbs: 4, fat: 1.5, emoji: '🍲'),
    ],
  ];

  static final List<List<ScheduleDish>> _lunchGain = [
    [
      ScheduleDish(name: 'Cơm trắng', portion: '2 chén đầy (250g)', calories: 325, protein: 6.8, carbs: 70, fat: 0.8, emoji: '🍚'),
      ScheduleDish(name: 'Bò xào ớt chuông hành tây', portion: '180g', calories: 340, protein: 36, carbs: 10, fat: 16, emoji: '🥩'),
      ScheduleDish(name: 'Đậu phụ sốt cà chua thịt băm', portion: '1 đĩa (150g)', calories: 220, protein: 16, carbs: 9, fat: 14, emoji: '🧈'),
      ScheduleDish(name: 'Canh xương hầm củ quả', portion: '1 tô', calories: 130, protein: 9, carbs: 12, fat: 5, emoji: '🍲'),
    ],
    [
      ScheduleDish(name: 'Cơm tấm sườn bì chả nướng', portion: '1 đĩa lớn', calories: 720, protein: 42, carbs: 80, fat: 24, emoji: '🍛'),
      ScheduleDish(name: 'Canh khổ qua nhồi thịt nạc', portion: '1 tô', calories: 110, protein: 11, carbs: 6, fat: 4.5, emoji: '🍲'),
    ],
    [
      ScheduleDish(name: 'Cơm gạo trắng', portion: '2 chén (250g)', calories: 325, protein: 6.8, carbs: 70, fat: 0.8, emoji: '🍚'),
      ScheduleDish(name: 'Cá hồi sốt bơ tỏi mè', portion: '170g', calories: 380, protein: 32, carbs: 4, fat: 26, emoji: '🐟'),
      ScheduleDish(name: 'Trứng chiên thịt băm', portion: '2 quả trứng + thịt', calories: 250, protein: 18, carbs: 3, fat: 18, emoji: '🍳'),
      ScheduleDish(name: 'Canh mồng tơi nấu cua đồng', portion: '1 tô', calories: 85, protein: 9, carbs: 7, fat: 2, emoji: '🍲'),
    ],
  ];

  static final List<List<ScheduleDish>> _dinnerLoss = [
    [
      ScheduleDish(name: 'Salad ức gà xé nấm đùi gà', portion: '1 đĩa lớn (200g)', calories: 260, protein: 38, carbs: 10, fat: 6, emoji: '🥗'),
      ScheduleDish(name: 'Khoai lang hấp nhỏ', portion: '80g', calories: 70, protein: 1.2, carbs: 16, fat: 0.1, emoji: '🍠'),
      ScheduleDish(name: 'Canh rong biển đậu phụ non', portion: '1 bát', calories: 55, protein: 6, carbs: 5, fat: 1.5, emoji: '🍲'),
    ],
    [
      ScheduleDish(name: 'Cá rô phi phi lê nướng giấy bạc', portion: '160g', calories: 210, protein: 34, carbs: 0, fat: 7, emoji: '🐟'),
      ScheduleDish(name: 'Rau luộc thập cẩm (cà rốt, su su, cải)', portion: '150g', calories: 45, protein: 2, carbs: 9, fat: 0.3, emoji: '🥦'),
      ScheduleDish(name: 'Canh chua cá bông lau ít ngọt', portion: '1 bát', calories: 80, protein: 10, carbs: 6, fat: 2, emoji: '🍲'),
    ],
    [
      ScheduleDish(name: 'Đậu phụ áp chảo sả ớt', portion: '120g', calories: 120, protein: 12, carbs: 4, fat: 6.5, emoji: '🧈'),
      ScheduleDish(name: 'Tôm nõn hấp bia sả', portion: '100g', calories: 99, protein: 24, carbs: 0.2, fat: 0.3, emoji: '🦐'),
      ScheduleDish(name: 'Rau muống luộc chấm tương gừng', portion: '150g', calories: 30, protein: 3, carbs: 4, fat: 0.3, emoji: '🥬'),
    ],
    [
      ScheduleDish(name: 'Bún chả nạc thanh đạm nước mắm chua ngọt', portion: '1 suất nhỏ', calories: 320, protein: 22, carbs: 42, fat: 6, emoji: '🍜'),
      ScheduleDish(name: 'Rau sống ăn kèm dồi dào', portion: '1 rổ nhỏ', calories: 20, protein: 1.5, carbs: 3, fat: 0.2, emoji: '🥗'),
    ],
  ];

  static final List<List<ScheduleDish>> _dinnerGain = [
    [
      ScheduleDish(name: 'Cơm trắng hạt dẻo thơm', portion: '2 chén (250g)', calories: 325, protein: 6.8, carbs: 70, fat: 0.8, emoji: '🍚'),
      ScheduleDish(name: 'Thịt kho trứng cút nước dừa', portion: '1 đĩa (150g)', calories: 360, protein: 26, carbs: 8, fat: 24, emoji: '🥩'),
      ScheduleDish(name: 'Đậu cove xào thịt bò', portion: '150g', calories: 180, protein: 16, carbs: 9, fat: 8, emoji: '🥗'),
      ScheduleDish(name: 'Canh chua cá lóc nấu dọc mùng', portion: '1 tô', calories: 110, protein: 14, carbs: 7, fat: 3, emoji: '🍲'),
    ],
    [
      ScheduleDish(name: 'Mì Ý sốt bò bằm phô mai sợi', portion: '1 đĩa lớn (250g)', calories: 650, protein: 35, carbs: 75, fat: 22, emoji: '🍝'),
      ScheduleDish(name: 'Salad sốt dầu mè béo ngậy', portion: '1 đĩa', calories: 120, protein: 2, carbs: 6, fat: 10, emoji: '🥗'),
    ],
    [
      ScheduleDish(name: 'Cơm trắng', portion: '1.5 chén (200g)', calories: 260, protein: 5.4, carbs: 56, fat: 0.6, emoji: '🍚'),
      ScheduleDish(name: 'Gà nướng mật ong nguyên đùi', portion: '1 cái lớn (200g)', calories: 420, protein: 38, carbs: 12, fat: 23, emoji: '🍗'),
      ScheduleDish(name: 'Canh sườn hầm bí đỏ', portion: '1 tô', calories: 180, protein: 14, carbs: 15, fat: 7, emoji: '🍲'),
    ],
  ];

  static final List<List<ScheduleDish>> _snackLoss = [
    [
      ScheduleDish(name: 'Sữa chua Hy Lạp không đường', portion: '1 hũ 100g', calories: 75, protein: 10, carbs: 4, fat: 2, emoji: '🥛'),
      ScheduleDish(name: 'Táo giòn thái hạt lựu', portion: '1/2 quả (80g)', calories: 42, protein: 0.3, carbs: 11, fat: 0.2, emoji: '🍎'),
    ],
    [
      ScheduleDish(name: 'Hạnh nhân sấy mộc nguyên vị', portion: '10 hạt (15g)', calories: 90, protein: 3.2, carbs: 3, fat: 7.5, emoji: '🥜'),
      ScheduleDish(name: 'Nước dừa tươi nguyên chất', portion: '1 ly 150ml', calories: 30, protein: 0.5, carbs: 6, fat: 0.2, emoji: '🥥'),
    ],
    [
      ScheduleDish(name: 'Chuối già Nam Mỹ', portion: '1 quả nhỏ (90g)', calories: 80, protein: 1, carbs: 20, fat: 0.2, emoji: '🍌'),
      ScheduleDish(name: 'Sữa đậu nành nguyên chất không đường', portion: '1 ly 150ml', calories: 50, protein: 4.5, carbs: 3, fat: 2, emoji: '🥛'),
    ],
    [
      ScheduleDish(name: 'Cam sành bóc múi mọng nước', portion: '1 quả (120g)', calories: 56, protein: 1.1, carbs: 14, fat: 0.2, emoji: '🍊'),
      ScheduleDish(name: 'Trứng gà luộc', portion: '1 quả', calories: 78, protein: 6.3, carbs: 0.6, fat: 5, emoji: '🥚'),
    ],
  ];

  static final List<List<ScheduleDish>> _snackGain = [
    [
      ScheduleDish(name: 'Sinh tố bơ chuối sữa chua béo', portion: '1 ly lớn (300ml)', calories: 320, protein: 8, carbs: 42, fat: 14, emoji: '🥑'),
      ScheduleDish(name: 'Hạt điều rang muối thơm bùi', portion: '30g', calories: 170, protein: 5, carbs: 9, fat: 13, emoji: '🥜'),
    ],
    [
      ScheduleDish(name: 'Bánh mì sandwich bơ đậu phộng & chuối', portion: '2 lát', calories: 360, protein: 12, carbs: 45, fat: 15, emoji: '🥪'),
      ScheduleDish(name: 'Sữa tươi tiệt trùng có đường', portion: '1 hộp 180ml', calories: 140, protein: 6, carbs: 16, fat: 6, emoji: '🥛'),
    ],
    [
      ScheduleDish(name: 'Ngũ cốc Granola trộn mật ong & sữa tươi', portion: '1 bát (80g)', calories: 340, protein: 9, carbs: 52, fat: 11, emoji: '🥣'),
      ScheduleDish(name: 'Trứng luộc hoặc chả quế', portion: '1 phần', calories: 120, protein: 8, carbs: 2, fat: 9, emoji: '🥚'),
    ],
  ];

  static MealPlanSchedule generate({
    required String goal,
    required int durationDays,
    required int targetCalories,
  }) {
    final isLoss = goal == 'lose';

    // Macros phân bổ
    final proteinRatio = isLoss ? 0.32 : 0.28;
    final carbsRatio = isLoss ? 0.40 : 0.45;
    final fatRatio = isLoss ? 0.28 : 0.27;

    final targetProtein = ((targetCalories * proteinRatio) / 4).round();
    final targetCarbs = ((targetCalories * carbsRatio) / 4).round();
    final targetFat = ((targetCalories * fatRatio) / 9).round();

    final List<ScheduleDay> days = [];
    final random = Random();

    final breakfastPool = isLoss ? _breakfastLoss : _breakfastGain;
    final lunchPool = isLoss ? _lunchLoss : _lunchGain;
    final dinnerPool = isLoss ? _dinnerLoss : _dinnerGain;
    final snackPool = isLoss ? _snackLoss : _snackGain;

    for (int day = 1; day <= durationDays; day++) {
      final bIndex = (day - 1 + random.nextInt(2)) % breakfastPool.length;
      final lIndex = (day - 1 + random.nextInt(2)) % lunchPool.length;
      final dIndex = (day - 1 + random.nextInt(2)) % dinnerPool.length;
      final sIndex = (day - 1 + random.nextInt(2)) % snackPool.length;

      final meals = [
        ScheduleMeal(
          type: 'breakfast',
          name: 'Bữa Sáng',
          time: '07:00 - 08:00',
          icon: '🌅',
          dishes: List.from(breakfastPool[bIndex]),
        ),
        ScheduleMeal(
          type: 'lunch',
          name: 'Bữa Trưa',
          time: '12:00 - 13:00',
          icon: '☀️',
          dishes: List.from(lunchPool[lIndex]),
        ),
        ScheduleMeal(
          type: 'snack',
          name: 'Bữa Phụ',
          time: '15:30 - 16:00',
          icon: '🍎',
          dishes: List.from(snackPool[sIndex]),
        ),
        ScheduleMeal(
          type: 'dinner',
          name: 'Bữa Tối',
          time: '18:30 - 19:30',
          icon: '🌙',
          dishes: List.from(dinnerPool[dIndex]),
        ),
      ];

      days.add(ScheduleDay(
        dayNumber: day,
        title: 'Ngày $day',
        meals: meals,
      ));
    }

    return MealPlanSchedule(
      id: 'schedule_${DateTime.now().millisecondsSinceEpoch}',
      goal: goal,
      durationDays: durationDays,
      dailyCalorieTarget: targetCalories,
      dailyProtein: targetProtein,
      dailyCarbs: targetCarbs,
      dailyFat: targetFat,
      createdAt: DateTime.now(),
      days: days,
    );
  }
}

// ==========================================
// MÀN HÌNH CHÍNH: LÊN LỊCH TRÌNH TĂNG GIẢM CÂN
// (Theo flow yêu cầu từ ảnh đề bài)
// ==========================================

class SchedulePlanScreen extends StatefulWidget {
  const SchedulePlanScreen({super.key});

  @override
  State<SchedulePlanScreen> createState() => _SchedulePlanScreenState();
}

class _SchedulePlanScreenState extends State<SchedulePlanScreen> {
  static const String _storageKey = 'nutrimate_active_schedule_thien';

  // 1. Dữ liệu đầu vào màn hình Tạo Lịch trình
  String _selectedGoal = 'lose'; // 'lose' (Giảm cân) hoặc 'gain' (Tăng cân)
  double _durationDays = 7; // Mặc định 7 ngày, khoảng 3 - 30 ngày

  // 2. Trạng thái hệ thống tính toán (1.5s loading)
  bool _isCalculating = false;
  bool _isLoadingInitial = true;

  // 3. Kết quả Lịch trình chi tiết
  MealPlanSchedule? _activeSchedule;

  // Quản lý ngày đang chọn để xem chi tiết
  int _selectedDayIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadSavedSchedule();
  }

  Future<void> _loadSavedSchedule() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedJson = prefs.getString(_storageKey);
      if (savedJson != null) {
        final decoded = jsonDecode(savedJson);
        setState(() {
          _activeSchedule = MealPlanSchedule.fromJson(decoded);
          _selectedGoal = _activeSchedule!.goal;
          _durationDays = _activeSchedule!.durationDays.toDouble();
        });
      }
    } catch (e) {
      // Bỏ qua lỗi parse
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingInitial = false;
        });
      }
    }
  }

  Future<void> _saveSchedule(MealPlanSchedule schedule) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(schedule.toJson()));
    } catch (_) {}
  }

  /// 3. Hệ thống tính toán (1.5s loading) & tạo lịch trình
  Future<void> _generateSchedule() async {
    final userProvider = context.read<UserProvider>();
    final profile = userProvider.profile;

    setState(() {
      _isCalculating = true;
    });

    // 1.5s loading chính xác theo yêu cầu
    await Future.delayed(const Duration(milliseconds: 1500));

    int targetCalories;
    if (profile != null) {
      final tdee = NutritionService.calculateTDEE(profile);
      if (_selectedGoal == 'lose') {
        targetCalories = max(1200, tdee - 500);
      } else {
        targetCalories = tdee + 350;
      }
    } else {
      // Mặc định chuẩn nếu người dùng chưa điền profile
      targetCalories = _selectedGoal == 'lose' ? 1650 : 2350;
    }

    final schedule = ScheduleGenerator.generate(
      goal: _selectedGoal,
      durationDays: _durationDays.round(),
      targetCalories: targetCalories,
    );

    await _saveSchedule(schedule);

    if (mounted) {
      setState(() {
        _activeSchedule = schedule;
        _isCalculating = false;
        _selectedDayIndex = 0;
      });
    }
  }

  void _resetSchedule() {
    setState(() {
      _activeSchedule = null;
      _selectedDayIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text(
          'Lịch trình tăng giảm cân',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_activeSchedule != null && !_isCalculating)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Tạo lịch trình mới',
              onPressed: _resetSchedule,
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoadingInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    // 3. Hệ thống tính toán (1.5s loading)
    if (_isCalculating) {
      return _buildCalculatingView();
    }

    // 4. Hiển thị Chi tiết Lịch trình
    if (_activeSchedule != null) {
      return _buildScheduleDetailView(_activeSchedule!);
    }

    // 2. Màn hình Tạo Lịch trình
    return _buildCreateScheduleForm();
  }

  // ==========================================
  // VIEW: 2. MÀN HÌNH TẠO LỊCH TRÌNH
  // ==========================================
  Widget _buildCreateScheduleForm() {
    final userProvider = context.watch<UserProvider>();
    final profile = userProvider.profile;
    final estimatedTdee = profile != null ? NutritionService.calculateTDEE(profile) : 2000;
    final estimatedTarget = _selectedGoal == 'lose' ? (estimatedTdee - 500) : (estimatedTdee + 350);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner giới thiệu
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              children: [
                const Text('🗓️', style: TextStyle(fontSize: 40)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Kế hoạch Dinh dưỡng Cá nhân',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Lên thực đơn chuẩn calo & macronutrient theo thời gian bạn mong muốn.',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 1. Chọn mục tiêu: Giảm cân / Tăng cân
          const Text(
            '1. Chọn mục tiêu của bạn',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildGoalCard(
                  title: 'Giảm cân',
                  subtitle: '-500 kcal/ngày',
                  icon: '📉',
                  value: 'lose',
                  color: const Color(0xFFE91E63),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildGoalCard(
                  title: 'Tăng cân',
                  subtitle: '+350 kcal/ngày',
                  icon: '📈',
                  value: 'gain',
                  color: const Color(0xFF2196F3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // 2. Kéo thanh trượt chọn số ngày (3-30 ngày)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '2. Thời gian lịch trình',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${_durationDays.round()} ngày',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Chọn khoảng thời gian áp dụng thực đơn từ 3 đến 30 ngày',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),

          // Thanh trượt Slider (3-30 ngày)
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF4CAF50),
              thumbColor: const Color(0xFF2E7D32),
              overlayColor: const Color(0xFF4CAF50).withValues(alpha: 0.2),
              trackHeight: 6,
              valueIndicatorColor: const Color(0xFF2E7D32),
              valueIndicatorTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            child: Slider(
              value: _durationDays,
              min: 3,
              max: 30,
              divisions: 27,
              label: '${_durationDays.round()} ngày',
              onChanged: (val) {
                setState(() {
                  _durationDays = val;
                });
              },
            ),
          ),

          // Phím tắt chọn nhanh số ngày
          Wrap(
            spacing: 8,
            children: [3, 7, 14, 21, 30].map((d) {
              final isSelected = _durationDays.round() == d;
              return ChoiceChip(
                label: Text('$d ngày'),
                selected: isSelected,
                selectedColor: const Color(0xFF4CAF50),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: (_) {
                  setState(() {
                    _durationDays = d.toDouble();
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Dự tính mục tiêu calo
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 1,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: (_selectedGoal == 'lose' ? Colors.pink : Colors.blue).withValues(alpha: 0.15),
                    radius: 24,
                    child: Text(_selectedGoal == 'lose' ? '🔥' : '⚡', style: const TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Mục tiêu năng lượng ước tính:', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        const SizedBox(height: 2),
                        Text(
                          '$estimatedTarget kcal / ngày',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                        ),
                        Text(
                          _selectedGoal == 'lose'
                              ? 'Giúp thâm hụt calo lành mạnh, giảm mỡ an toàn'
                              : 'Giúp thặng dư calo tích cực, tăng cân tăng cơ',
                          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),

          // Nút "Tạo lịch trình ngay"
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _generateSchedule,
              icon: const Text('✨', style: TextStyle(fontSize: 20)),
              label: const Text(
                'Tạo lịch trình ngay',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 3,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildGoalCard({
    required String title,
    required String subtitle,
    required String icon,
    required String value,
    required Color color,
  }) {
    final isSelected = _selectedGoal == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGoal = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2.5 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : null,
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? color : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? color.withValues(alpha: 0.8) : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // VIEW: 3. HỆ THỐNG TÍNH TOÁN (1.5s LOADING)
  // ==========================================
  Widget _buildCalculatingView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 90,
                  height: 90,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                    backgroundColor: Colors.grey.shade200,
                  ),
                ),
                const Text('🗓️', style: TextStyle(fontSize: 42)),
              ],
            ),
            const SizedBox(height: 28),
            const Text(
              'Hệ thống đang tính toán...',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 8),
            Text(
              'Đang cân bằng calo và thiết kế thực đơn ${_durationDays.round()} ngày cho bạn',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.bolt, color: Colors.green, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Phân bổ 4 bữa: Sáng, Trưa, Tối, Phụ',
                    style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // VIEW: 4. HIỂN THỊ CHI TIẾT LỊCH TRÌNH
  // ==========================================
  Widget _buildScheduleDetailView(MealPlanSchedule schedule) {
    if (_selectedDayIndex >= schedule.days.length) {
      _selectedDayIndex = 0;
    }
    final currentDay = schedule.days[_selectedDayIndex];

    return Column(
      children: [
        // 1. TỔNG QUAN: MỤC TIÊU CALO/NGÀY & MACROS
        _buildOverviewHeader(schedule),

        // 2. DANH SÁCH TỪNG NGÀY (DAY 1, DAY 2, ...)
        _buildDaysBar(schedule),

        // 3. CHI TIẾT BỮA ĂN CỦA NGÀY ĐANG CHỌN (4 BỮA: SÁNG, TRƯA, TỐI, PHỤ)
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Thực đơn ${currentDay.title}',
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                    Text(
                      'Tổng: ${currentDay.totalCalories.round()} kcal',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
              ),
              ...currentDay.meals.map((meal) => _buildMealCard(meal)),
              const SizedBox(height: 16),
              // Nút tạo lại hoặc chuyển mục tiêu
              OutlinedButton.icon(
                onPressed: _resetSchedule,
                icon: const Icon(Icons.edit_calendar),
                label: const Text('Thay đổi mục tiêu / số ngày'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2E7D32),
                  side: const BorderSide(color: Color(0xFF4CAF50)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewHeader(MealPlanSchedule schedule) {
    final isLoss = schedule.goal == 'lose';
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (isLoss ? Colors.pink : Colors.blue).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(isLoss ? '📉' : '📈', style: const TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isLoss ? 'Lịch trình Giảm cân' : 'Lịch trình Tăng cân',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Thời gian: ${schedule.durationDays} ngày',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_fire_department, color: Colors.orange, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${schedule.dailyCalorieTarget} kcal/ngày',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMacroItem('Protein', '${schedule.dailyProtein}g', Colors.orange),
              _buildMacroItem('Carbs', '${schedule.dailyCarbs}g', Colors.blue),
              _buildMacroItem('Fat', '${schedule.dailyFat}g', Colors.pink),
              _buildMacroItem('Bữa ăn/ngày', '4 bữa', Colors.teal),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      ],
    );
  }

  // Thanh chọn từng ngày (Day 1, Day 2, Day 3, ...)
  Widget _buildDaysBar(MealPlanSchedule schedule) {
    return Container(
      height: 52,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: schedule.days.length,
        itemBuilder: (context, index) {
          final day = schedule.days[index];
          final isSelected = index == _selectedDayIndex;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                setState(() {
                  _selectedDayIndex = index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF4CAF50) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF4CAF50) : Colors.grey.shade300,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.green.withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                child: Text(
                  'Day ${day.dayNumber}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Card hiển thị 1 bữa ăn (Sáng, Trưa, Tối, Phụ) và bấm để xem chi tiết món
  Widget _buildMealCard(ScheduleMeal meal) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _getMealColor(meal.type).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(meal.icon, style: const TextStyle(fontSize: 22)),
          ),
          title: Row(
            children: [
              Text(
                meal.name,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  meal.time,
                  style: TextStyle(fontSize: 10, color: Colors.grey[700]),
                ),
              ),
            ],
          ),
          subtitle: Text(
            '${meal.totalCalories.round()} kcal • ${meal.dishes.length} món',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Column(
                children: meal.dishes.map((dish) => _buildDishItem(dish)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDishItem(ScheduleDish dish) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(dish.emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dish.name,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 2),
                Text(
                  'Khẩu phần: ${dish.portion}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildMiniMacro('P', '${dish.protein.toStringAsFixed(0)}g', Colors.orange),
                    const SizedBox(width: 8),
                    _buildMiniMacro('C', '${dish.carbs.toStringAsFixed(0)}g', Colors.blue),
                    const SizedBox(width: 8),
                    _buildMiniMacro('F', '${dish.fat.toStringAsFixed(0)}g', Colors.pink),
                  ],
                ),
              ],
            ),
          ),
          Text(
            '${dish.calories.round()} kcal',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMacro(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Color _getMealColor(String type) {
    switch (type) {
      case 'breakfast':
        return Colors.orange;
      case 'lunch':
        return Colors.amber.shade800;
      case 'dinner':
        return Colors.indigo;
      case 'snack':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }
}
