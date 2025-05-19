class AppConstants {
  // App info
  static const String appName = 'Daily Health Tracker';
  static const String appVersion = '1.0.0';
  
  // Navigation items
  static const int dashboardIndex = 0;
  static const int historyIndex = 1;
  static const int addEntryIndex = 2;
  static const int settingsIndex = 3;
  
  // Default values
  static const int defaultWaterTarget = 2000; // ml
  static const int defaultStepsTarget = 10000;
  static const double defaultSleepTarget = 8.0; // hours
  
  // Units
  static const Map<String, double> waterUnitConversions = {
    'ml': 1.0,
    'cups': 236.588, // 1 cup = 236.588 ml
  };
  
  static const Map<String, double> weightUnitConversions = {
    'kg': 1.0,
    'lbs': 0.453592, // 1 lb = 0.453592 kg
  };
}