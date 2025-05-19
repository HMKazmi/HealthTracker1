import 'package:flutter/material.dart' show TimeOfDay;

class UserSettings {
  final bool isDarkMode;
  final String weightUnit; // 'kg' or 'lbs'
  final String waterUnit; // 'ml' or 'cups'
  final TimeOfDay reminderTime;
  final bool notificationsEnabled;
  
  UserSettings({
    required this.isDarkMode,
    required this.weightUnit,
    required this.waterUnit,
    required this.reminderTime,
    required this.notificationsEnabled,
  });
  
  // Default settings
  factory UserSettings.defaultSettings() {
    return UserSettings(
      isDarkMode: false,
      weightUnit: 'kg',
      waterUnit: 'ml',
      reminderTime: const TimeOfDay(hour: 21, minute: 0), // 9:00 PM
      notificationsEnabled: true,
    );
  }
  
  // Create a copy with some fields replaced
  UserSettings copyWith({
    bool? isDarkMode,
    String? weightUnit,
    String? waterUnit,
    TimeOfDay? reminderTime,
    bool? notificationsEnabled,
  }) {
    return UserSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      weightUnit: weightUnit ?? this.weightUnit,
      waterUnit: waterUnit ?? this.waterUnit,
      reminderTime: reminderTime ?? this.reminderTime,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
  
  // Convert to a map for storage
  Map<String, dynamic> toMap() {
    return {
      'isDarkMode': isDarkMode,
      'weightUnit': weightUnit,
      'waterUnit': waterUnit,
      'reminderHour': reminderTime.hour,
      'reminderMinute': reminderTime.minute,
      'notificationsEnabled': notificationsEnabled,
    };
  }
  
  // Create settings from a map
  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      isDarkMode: map['isDarkMode'] ?? false,
      weightUnit: map['weightUnit'] ?? 'kg',
      waterUnit: map['waterUnit'] ?? 'ml',
      reminderTime: TimeOfDay(
        hour: map['reminderHour'] ?? 21,
        minute: map['reminderMinute'] ?? 0,
      ),
      notificationsEnabled: map['notificationsEnabled'] ?? true,
    );
  }
}