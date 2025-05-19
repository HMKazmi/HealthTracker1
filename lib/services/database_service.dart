import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/health_entry.dart';
import '../models/user_settings.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;
  SharedPreferences? _prefs;
  
  // Initialize the database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize shared preferences
  Future<SharedPreferences> get prefs async {
    if (_prefs != null) return _prefs!;
    _prefs = await SharedPreferences.getInstance();
    return _prefs!;
  }
  
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'health_tracker.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
  }
  
  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE health_entries(
        id TEXT PRIMARY KEY,
        date INTEGER NOT NULL,
        waterIntake INTEGER NOT NULL,
        sleepHours REAL NOT NULL,
        steps INTEGER NOT NULL,
        mood INTEGER NOT NULL,
        weight REAL NOT NULL
      )
    ''');
  }
  
  // CRUD operations for health entries
  
  Future<String> insertHealthEntry(HealthEntry entry) async {
    final db = await database;
    await db.insert(
      'health_entries',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return entry.id;
  }
  
  Future<HealthEntry?> getHealthEntryForDate(DateTime date) async {
    final db = await database;
    
    // Normalize the date to start of day
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    
    final List<Map<String, dynamic>> maps = await db.query(
      'health_entries',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch],
    );
    
    if (maps.isEmpty) {
      return null;
    }
    
    return HealthEntry.fromMap(maps.first);
  }
  
  Future<List<HealthEntry>> getHealthEntriesForRange(DateTime start, DateTime end) async {
    final db = await database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'health_entries',
      where: 'date >= ? AND date <= ?',
      whereArgs: [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
      orderBy: 'date DESC',
    );
    
    return List.generate(maps.length, (i) {
      return HealthEntry.fromMap(maps[i]);
    });
  }
  
  Future<void> updateHealthEntry(HealthEntry entry) async {
    final db = await database;
    
    await db.update(
      'health_entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }
  
  Future<void> deleteHealthEntry(String id) async {
    final db = await database;
    
    await db.delete(
      'health_entries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // User settings operations
  
  Future<void> saveUserSettings(UserSettings settings) async {
    final pref = await prefs;
    final settingsMap = settings.toMap();
    
    for (final entry in settingsMap.entries) {
      switch (entry.value.runtimeType) {
        case bool:
          await pref.setBool(entry.key, entry.value);
          break;
        case String:
          await pref.setString(entry.key, entry.value);
          break;
        case int:
          await pref.setInt(entry.key, entry.value);
          break;
        case double:
          await pref.setDouble(entry.key, entry.value);
          break;
        default:
          // Skip unsupported types
          break;
      }
    }
  }
  
  Future<UserSettings> getUserSettings() async {
    final pref = await prefs;
    
    return UserSettings(
      isDarkMode: pref.getBool('isDarkMode') ?? false,
      weightUnit: pref.getString('weightUnit') ?? 'kg',
      waterUnit: pref.getString('waterUnit') ?? 'ml',
      reminderTime: TimeOfDay(
        hour: pref.getInt('reminderHour') ?? 21,
        minute: pref.getInt('reminderMinute') ?? 0,
      ),
      notificationsEnabled: pref.getBool('notificationsEnabled') ?? true,
    );
  }
}