import 'package:flutter/material.dart';

class HealthEntry {
  final String id;
  final DateTime date;
  final int waterIntake; // in ml
  final double sleepHours;
  final int steps;
  final MoodType mood;
  final double weight; // in kg
  
  HealthEntry({
    required this.id,
    required this.date,
    required this.waterIntake,
    required this.sleepHours,
    required this.steps,
    required this.mood,
    required this.weight,
  });
  
  // Factory constructor to create an entry with today's date and default values
  factory HealthEntry.today() {
    return HealthEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      waterIntake: 0,
      sleepHours: 0,
      steps: 0,
      mood: MoodType.neutral,
      weight: 0,
    );
  }
  
  // Create a copy of this entry with some fields replaced
  HealthEntry copyWith({
    String? id,
    DateTime? date,
    int? waterIntake,
    double? sleepHours,
    int? steps,
    MoodType? mood,
    double? weight,
  }) {
    return HealthEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      waterIntake: waterIntake ?? this.waterIntake,
      sleepHours: sleepHours ?? this.sleepHours,
      steps: steps ?? this.steps,
      mood: mood ?? this.mood,
      weight: weight ?? this.weight,
    );
  }
  
  // Convert to a map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.millisecondsSinceEpoch,
      'waterIntake': waterIntake,
      'sleepHours': sleepHours,
      'steps': steps,
      'mood': mood.index,
      'weight': weight,
    };
  }
  
  // Create an entry from a database map
  factory HealthEntry.fromMap(Map<String, dynamic> map) {
    return HealthEntry(
      id: map['id'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      waterIntake: map['waterIntake'],
      sleepHours: map['sleepHours'],
      steps: map['steps'],
      mood: MoodType.values[map['mood']],
      weight: map['weight'],
    );
  }
}

// Enum to represent mood types
enum MoodType {
  veryBad,
  bad,
  neutral,
  good,
  veryGood
}

// Extension to provide emoji and color for each mood type
extension MoodTypeExtension on MoodType {
  String get emoji {
    switch (this) {
      case MoodType.veryBad: return '😢';
      case MoodType.bad: return '😔';
      case MoodType.neutral: return '😐';
      case MoodType.good: return '🙂';
      case MoodType.veryGood: return '😁';
    }
  }
  
  Color get color {
    switch (this) {
      case MoodType.veryBad: return Colors.red;
      case MoodType.bad: return Colors.orange;
      case MoodType.neutral: return Colors.yellow;
      case MoodType.good: return Colors.lightGreen;
      case MoodType.veryGood: return Colors.green;
    }
  }
  
  String get label {
    switch (this) {
      case MoodType.veryBad: return 'Very Bad';
      case MoodType.bad: return 'Bad';
      case MoodType.neutral: return 'Neutral';
      case MoodType.good: return 'Good';
      case MoodType.veryGood: return 'Very Good';
    }
  }
}