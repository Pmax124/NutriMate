import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrimate/screens/tinhnang_Thien.dart';
import 'package:nutrimate/providers/user_provider.dart';
import 'package:nutrimate/providers/food_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ScheduleGenerator Tests', () {
    test('generate schedule for 7 days lose weight', () {
      final schedule = ScheduleGenerator.generate(
        goal: 'lose',
        durationDays: 7,
        targetCalories: 1500,
      );

      expect(schedule.goal, equals('lose'));
      expect(schedule.durationDays, equals(7));
      expect(schedule.days.length, equals(7));
      expect(schedule.dailyCalorieTarget, equals(1500));

      for (var day in schedule.days) {
        expect(day.meals.length, equals(4)); // Sáng, Trưa, Phụ, Tối
        expect(day.meals.any((m) => m.name == 'Bữa Sáng'), isTrue);
        expect(day.meals.any((m) => m.name == 'Bữa Trưa'), isTrue);
        expect(day.meals.any((m) => m.name == 'Bữa Tối'), isTrue);
        expect(day.meals.any((m) => m.name == 'Bữa Phụ'), isTrue);

        for (var meal in day.meals) {
          expect(meal.dishes.isNotEmpty, isTrue);
          for (var dish in meal.dishes) {
            expect(dish.name.isNotEmpty, isTrue);
            expect(dish.calories, greaterThan(0));
          }
        }
      }
    });

    test('generate schedule for 30 days gain weight', () {
      final schedule = ScheduleGenerator.generate(
        goal: 'gain',
        durationDays: 30,
        targetCalories: 2400,
      );

      expect(schedule.goal, equals('gain'));
      expect(schedule.durationDays, equals(30));
      expect(schedule.days.length, equals(30));
      expect(schedule.dailyCalorieTarget, equals(2400));
    });

    test('toJson and fromJson serialization works', () {
      final original = ScheduleGenerator.generate(
        goal: 'lose',
        durationDays: 5,
        targetCalories: 1600,
      );

      final json = original.toJson();
      final revived = MealPlanSchedule.fromJson(json);

      expect(revived.id, equals(original.id));
      expect(revived.goal, equals(original.goal));
      expect(revived.durationDays, equals(5));
      expect(revived.days.length, equals(5));
      expect(revived.days[0].meals.length, equals(4));
    });
  });

  group('SchedulePlanScreen Widget Tests', () {
    testWidgets('renders initial form with goal selection, slider and button', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => UserProvider()),
            ChangeNotifierProvider(create: (_) => FoodProvider()),
          ],
          child: const MaterialApp(
            home: SchedulePlanScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify form elements exist
      expect(find.text('Lịch trình tăng giảm cân'), findsOneWidget);
      expect(find.text('Giảm cân'), findsOneWidget);
      expect(find.text('Tăng cân'), findsOneWidget);
      expect(find.text('Tạo lịch trình ngay'), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);
    });

    testWidgets('tap Tao lich trinh ngay triggers 1.5s calculation and shows detail', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => UserProvider()),
            ChangeNotifierProvider(create: (_) => FoodProvider()),
          ],
          child: const MaterialApp(
            home: SchedulePlanScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap "Tạo lịch trình ngay"
      final buttonFinder = find.text('Tạo lịch trình ngay');
      await tester.ensureVisible(buttonFinder);
      await tester.tap(buttonFinder);
      await tester.pump(); // Start loading

      // Should show calculating text
      expect(find.text('Hệ thống đang tính toán...'), findsOneWidget);

      // Advance clock by 1500ms
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();

      // Now detail view should be visible
      expect(find.text('Day 1'), findsWidgets);
      expect(find.text('Bữa Sáng'), findsOneWidget);
      expect(find.text('Bữa Trưa'), findsOneWidget);
      expect(find.text('Bữa Phụ'), findsOneWidget);
      expect(find.text('Bữa Tối'), findsOneWidget);
    });
  });
}
