import 'package:flutter/foundation.dart';
import '../models/health_entry.dart';
import '../services/database_service.dart';

class AddEntryViewModel extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  
  HealthEntry? _currentEntry;
  bool _isLoading = false;
  bool _isSaving = false;
  String _errorMessage = '';
  
  HealthEntry? get currentEntry => _currentEntry;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String get errorMessage => _errorMessage;
  
  // Initialize with today's date or a specific date
  Future<void> initialize([DateTime? date]) async {
    _setLoading(true);
    
    final targetDate = date ?? DateTime.now();
    
    try {
      // Try to get an existing entry for this date
      _currentEntry = await _databaseService.getHealthEntryForDate(targetDate);
      
      // If no entry exists, create a new one
      if (_currentEntry == null) {
        _currentEntry = HealthEntry(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          date: targetDate,
          waterIntake: 0,
          sleepHours: 0.0,
          steps: 0,
          mood: MoodType.neutral,
          weight: 0.0,
        );
      }
    } catch (e) {
      _errorMessage = 'Failed to load health entry: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }
  
  void updateWaterIntake(int value) {
    if (_currentEntry == null) return;
    _currentEntry = _currentEntry!.copyWith(waterIntake: value);
    notifyListeners();
  }
  
  void updateSleepHours(double value) {
    if (_currentEntry == null) return;
    _currentEntry = _currentEntry!.copyWith(sleepHours: value);
    notifyListeners();
  }
  
  void updateSteps(int value) {
    if (_currentEntry == null) return;
    _currentEntry = _currentEntry!.copyWith(steps: value);
    notifyListeners();
  }
  
  void updateMood(MoodType mood) {
    if (_currentEntry == null) return;
    _currentEntry = _currentEntry!.copyWith(mood: mood);
    notifyListeners();
  }
  
  void updateWeight(double value) {
    if (_currentEntry == null) return;
    _currentEntry = _currentEntry!.copyWith(weight: value);
    notifyListeners();
  }
  
  Future<bool> saveEntry() async {
    if (_currentEntry == null) return false;
    
    _isSaving = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      // Check if entry already exists by trying to get it from DB
      final existingEntry = await _databaseService.getHealthEntryForDate(_currentEntry!.date);
      
      if (existingEntry == null) {
        // Create new entry
        await _databaseService.insertHealthEntry(_currentEntry!);
      } else {
        // Update existing entry
        await _databaseService.updateHealthEntry(_currentEntry!);
      }
      
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to save health entry: ${e.toString()}';
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