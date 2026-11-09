import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'providers/food_provider.dart';
import 'screens/onboarding_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/food_log_screen.dart';
import 'screens/scan_food_screen.dart';
import 'screens/chat_ai_screen.dart';
import 'screens/meal_plan_screen.dart';
import 'screens/weight_tracker_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load .env file (không bắt buộc, app vẫn chạy demo nếu không có)
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print('Không tìm thấy file .env, chạy ở chế độ demo');
  }
  
  runApp(NutriMateApp());
}

class NutriMateApp extends StatelessWidget {
  const NutriMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()..loadProfile()),
        ChangeNotifierProvider(create: (_) => FoodProvider()),
      ],
      child: MaterialApp(
        title: 'NutriMate',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        home: AppHome(),
        routes: {
          '/profileSetup': (context) => ProfileSetupScreen(),
          '/dashboard': (context) => DashboardScreen(),
          '/foodLog': (context) => FoodLogScreen(),
          '/scanFood': (context) => ScanFoodScreen(),
          '/chatAI': (context) => ChatAIScreen(),
          '/mealPlan': (context) => MealPlanScreen(),
          '/weightTracker': (context) => WeightTrackerScreen(),
        },
      ),
    );
  }
}

class AppHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    if (userProvider.isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Nếu chưa setup profile → Onboarding
    if (userProvider.profile == null || !userProvider.profile!.hasCompletedSetup) {
      return OnboardingScreen(
        onStart: () => Navigator.pushNamed(context, '/profileSetup'),
      );
    }

    // Đã setup → Dashboard
    return DashboardScreen();
  }
}