import 'package:flutter/foundation.dart';
import '../models/health_entry.dart';
import '../services/database_service.dart';

class HistoryViewModel extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  
  List<HealthEntry> _entries = [];
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  bool _isLoading = false;
  String _errorMessage = '';
  
  List<HealthEntry> get entries => _entries;
  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  
  HistoryViewModel() {
    loadEntries();
  }
  
  Future<void> loadEntries() async {
    _setLoading(true);
    
    try {
      _entries = await _databaseService.getHealthEntriesForRange(_startDate, _endDate);
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Failed to load entries: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }
  
  void setDateRange(DateTime start, DateTime end) {
    // Make sure end date is after start date
    if (end.isBefore(start)) {
      final temp = start;
      _startDate = end;
      _endDate = temp;
    } else {
      _startDate = start;
      _endDate = end;
    }
    
    // Ensure end date includes the entire day
    _endDate = DateTime(_endDate.year, _endDate.month, _endDate.day, 23, 59, 59);
    
    loadEntries();
  }
  
  Future<void> deleteEntry(String id) async {
    _setLoading(true);
    
    try {
      await _databaseService.deleteHealthEntry(id);
      // Refresh the list after deletion
      await loadEntries();
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Failed to delete entry: ${e.toString()}';
      _setLoading(false);
    }
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  // Helper method to get average values for the current range
  Map<String, dynamic> getAverageValues() {
    if (_entries.isEmpty) {
      return {
        'waterIntake': 0,
        'sleepHours': 0.0,
        'steps': 0,
        'weight': 0.0,
      };
    }
    
    int totalWater = 0;
    double totalSleep = 0.0;
    int totalSteps = 0;
    double totalWeight = 0.0;
    int weightCount = 0; // Only count days where weight was recorded
    
    for (final entry in _entries) {
      totalWater += entry.waterIntake;
      totalSleep += entry.sleepHours;
      totalSteps += entry.steps;
      
      if (entry.weight > 0) {
        totalWeight += entry.weight;
        weightCount++;
      }
    }
    
    return {
      'waterIntake': totalWater ~/ _entries.length,
      'sleepHours': totalSleep / _entries.length,
      'steps': totalSteps ~/ _entries.length,
      'weight': weightCount > 0 ? totalWeight / weightCount : 0.0,
    };
  }
}