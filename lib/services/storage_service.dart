import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../models/food_log.dart';
import '../models/weight_entry.dart';
import '../models/water_log.dart';

class StorageService {
  static const String _profileKey = 'nutrimate_profile';
  static const String _foodLogsKey = 'nutrimate_food_logs';
  static const String _weightLogsKey = 'nutrimate_weight_logs';
  static const String _waterLogsKey = 'nutrimate_water_logs';

  // ===== PROFILE =====
  static Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(profile.toJson()));
  }

  static Future<UserProfile?> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_profileKey);
    if (data == null) return null;
    return UserProfile.fromJson(jsonDecode(data));
  }

  // ===== FOOD LOGS =====
  static Future<void> saveFoodLogs(List<FoodLog> logs) async {
    final prefs = await SharedPreferences.getInstance();
    final list = logs.map((l) => l.toJson()).toList();
    await prefs.setString(_foodLogsKey, jsonEncode(list));
  }

  static Future<List<FoodLog>> getFoodLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_foodLogsKey);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => FoodLog.fromJson(e)).toList();
  }

  // ===== WEIGHT LOGS =====
  static Future<void> saveWeightLogs(List<WeightEntry> logs) async {
    final prefs = await SharedPreferences.getInstance();
    final list = logs.map((l) => l.toJson()).toList();
    await prefs.setString(_weightLogsKey, jsonEncode(list));
  }

  static Future<List<WeightEntry>> getWeightLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_weightLogsKey);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => WeightEntry.fromJson(e)).toList();
  }

  // ===== WATER LOGS =====
  static Future<void> saveWaterLogs(List<WaterLog> logs) async {
    final prefs = await SharedPreferences.getInstance();
    final list = logs.map((l) => l.toJson()).toList();
    await prefs.setString(_waterLogsKey, jsonEncode(list));
  }

  static Future<List<WaterLog>> getWaterLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_waterLogsKey);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => WaterLog.fromJson(e)).toList();
  }
}