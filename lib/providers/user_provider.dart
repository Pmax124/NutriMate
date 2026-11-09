import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../models/nutrition_target.dart';
import '../services/storage_service.dart';
import '../services/nutrition_service.dart';

class UserProvider extends ChangeNotifier {
  UserProfile? _profile;
  NutritionTarget? _target;
  bool _isLoading = true;

  UserProfile? get profile => _profile;
  NutritionTarget? get target => _target;
  bool get isLoading => _isLoading;

  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      _profile = await StorageService.getProfile();
      if (_profile != null) {
        _target = NutritionService.calculateTarget(_profile!);
      }
    } catch (e) {
      print('Error loading profile: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateProfile(UserProfile profile) async {
    _profile = profile;
    _target = NutritionService.calculateTarget(profile);
    await StorageService.saveProfile(profile);
    notifyListeners();
  }

  Future<void> reset() async {
    _profile = null;
    _target = null;
    await StorageService.saveProfile(UserProfile(
      name: '',
      age: 0,
      gender: 'male',
      weightKg: 0,
      heightCm: 0,
      activityLevel: 'moderate',
      goal: 'maintain',
    ));
    notifyListeners();
  }
}