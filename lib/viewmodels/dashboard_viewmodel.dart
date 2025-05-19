import 'package:flutter/foundation.dart';
import '../models/health_entry.dart';
import '../services/database_service.dart';

class DashboardViewModel extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  HealthEntry? _todayEntry;
  List<HealthEntry> _weekEntries = [];
  bool _isLoading = false;
  
  HealthEntry? get todayEntry => _todayEntry;
  List<HealthEntry> get weekEntries => _weekEntries;
  bool get isLoading => _isLoading;
  
  DashboardViewModel() {
    _loadData();
  }
  
  Future<void> _loadData() async {
    _setLoading(true);
    await _loadTodayEntry();
    await _loadWeekEntries();
    _setLoading(false);
  }
  
  Future<void> _loadTodayEntry() async {
    final now = DateTime.now();
    _todayEntry = await _databaseService.getHealthEntryForDate(now);
    
    // If no entry exists for today, create one
    if (_todayEntry == null) {
      _todayEntry = HealthEntry.today();
      await _databaseService.insertHealthEntry(_todayEntry!);
    }
    
    notifyListeners();
  }
  
  Future<void> _loadWeekEntries() async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 6));
    
    // Get start and end of day
    final startDate = DateTime(weekAgo.year, weekAgo.month, weekAgo.day);
    final endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
    
    _weekEntries = await _databaseService.getHealthEntriesForRange(startDate, endDate);
    notifyListeners();
  }
  
  Future<void> refreshData() async {
    await _loadData();
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  // Calculate progress percentages for today's metrics
  double getWaterProgress() {
    if (_todayEntry == null) return 0.0;
    return (_todayEntry!.waterIntake / 2000).clamp(0.0, 1.0); // Assuming 2000ml target
  }
  
  double getStepsProgress() {
    if (_todayEntry == null) return 0.0;
    return (_todayEntry!.steps / 10000).clamp(0.0, 1.0); // Assuming 10000 steps target
  }
  
  double getSleepProgress() {
    if (_todayEntry == null) return 0.0;
    return (_todayEntry!.sleepHours / 8).clamp(0.0, 1.0); // Assuming 8 hours target
  }
  
  // Get data for charts
  List<Map<String, dynamic>> getWaterChartData() {
    return _weekEntries.map((entry) {
      return {
        'date': entry.date,
        'value': entry.waterIntake,
      };
    }).toList();
  }
  
  List<Map<String, dynamic>> getStepsChartData() {
    return _weekEntries.map((entry) {
      return {
        'date': entry.date,
        'value': entry.steps,
      };
    }).toList();
  }
  
  List<Map<String, dynamic>> getSleepChartData() {
    return _weekEntries.map((entry) {
      return {
        'date': entry.date,
        'value': entry.sleepHours,
      };
    }).toList();
  }
  
  List<Map<String, dynamic>> getWeightChartData() {
    return _weekEntries.map((entry) {
      return {
        'date': entry.date,
        'value': entry.weight,
      };
    }).toList();
  }
  
  List<Map<String, dynamic>> getMoodChartData() {
    return _weekEntries.map((entry) {
      return {
        'date': entry.date,
        'value': entry.mood.index,
      };
    }).toList();
  }
}