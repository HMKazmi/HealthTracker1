import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/user_settings.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class SettingsViewModel extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final NotificationService _notificationService = NotificationService();
  
  UserSettings _settings = UserSettings.defaultSettings();
  bool _isLoading = false;
  bool _isSaving = false;
  String _errorMessage = '';
  
  UserSettings get settings => _settings;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String get errorMessage => _errorMessage;
  
  SettingsViewModel() {
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    _setLoading(true);
    
    try {
      _settings = await _databaseService.getUserSettings();
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Failed to load settings: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }
  
  void updateThemeMode(bool isDarkMode) {
    _settings = _settings.copyWith(isDarkMode: isDarkMode);
    notifyListeners();
  }
  
  void updateWeightUnit(String unit) {
    if (unit != 'kg' && unit != 'lbs') return;
    _settings = _settings.copyWith(weightUnit: unit);
    notifyListeners();
  }
  
  void updateWaterUnit(String unit) {
    if (unit != 'ml' && unit != 'cups') return;
    _settings = _settings.copyWith(waterUnit: unit);
    notifyListeners();
  }
  
  void updateReminderTime(TimeOfDay time) {
    _settings = _settings.copyWith(reminderTime: time);
    notifyListeners();
  }
  
  void toggleNotifications(bool enabled) {
    _settings = _settings.copyWith(notificationsEnabled: enabled);
    
    if (enabled) {
      _updateNotifications();
    } else {
      _notificationService.cancelAllNotifications();
    }
    
    notifyListeners();
  }
  
  Future<void> _updateNotifications() async {
    if (_settings.notificationsEnabled) {
      await _notificationService.cancelAllNotifications();
      await _notificationService.scheduleHealthTrackingReminder(_settings.reminderTime);
    }
  }
  
  Future<bool> saveSettings() async {
    _isSaving = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      await _databaseService.saveUserSettings(_settings);
      await _updateNotifications();
      
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to save settings: ${e.toString()}';
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}