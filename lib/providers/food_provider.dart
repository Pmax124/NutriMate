import 'package:flutter/material.dart';
import '../models/food_log.dart';
import '../models/weight_entry.dart';
import '../models/water_log.dart';
import '../services/storage_service.dart';

class FoodProvider extends ChangeNotifier {
  List<FoodLog> _logs = [];
  List<WeightEntry> _weightLogs = [];
  List<WaterLog> _waterLogs = [];

  List<FoodLog> get logs => _logs;
  List<WeightEntry> get weightLogs => _weightLogs;
  List<WaterLog> get waterLogs => _waterLogs;

  // Tính tổng hôm nay
  double get todayCalories => _calculateTodayTotal((log) => log.totalCalories);
  double get todayProtein => _calculateTodayTotal((log) => log.totalProtein);
  double get todayCarbs => _calculateTodayTotal((log) => log.totalCarbs);
  double get todayFat => _calculateTodayTotal((log) => log.totalFat);
  int get todayWaterGlasses => _getTodayWaterGlasses();

  Future<void> loadAll() async {
    _logs = await StorageService.getFoodLogs();
    _weightLogs = await StorageService.getWeightLogs();
    _waterLogs = await StorageService.getWaterLogs();
    notifyListeners();
  }

  Future<void> addFoodLog(FoodLog log) async {
    _logs.insert(0, log);
    await StorageService.saveFoodLogs(_logs);
    notifyListeners();
  }

  Future<void> removeFoodLog(String id) async {
    _logs.removeWhere((l) => l.id == id);
    await StorageService.saveFoodLogs(_logs);
    notifyListeners();
  }

  Future<void> addWeight(double weight) async {
    final entry = WeightEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      weight: weight,
      timestamp: DateTime.now(),
    );
    _weightLogs.insert(0, entry);
    await StorageService.saveWeightLogs(_weightLogs);
    notifyListeners();
  }

  Future<void> addWater() async {
    final today = _getTodayKey();
    final idx = _waterLogs.indexWhere((w) => w.date == today);

    if (idx >= 0) {
      _waterLogs[idx] = WaterLog(date: today, glasses: _waterLogs[idx].glasses + 1);
    } else {
      _waterLogs.add(WaterLog(date: today, glasses: 1));
    }

    await StorageService.saveWaterLogs(_waterLogs);
    notifyListeners();
  }

  double _calculateTodayTotal(double Function(FoodLog) selector) {
    final today = _getTodayKey();
    return _logs
        .where((l) => _getDateKey(l.timestamp) == today)
        .fold(0.0, (sum, log) => sum + selector(log));
  }

  int _getTodayWaterGlasses() {
    final today = _getTodayKey();
    final entry = _waterLogs.where((w) => w.date == today).firstOrNull;
    return entry?.glasses ?? 0;
  }

  String _getTodayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  String _getDateKey(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
}