import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../utils/app_exception.dart';
import '../utils/constants.dart';

/// Owns the single sqflite [Database] connection: schema creation, indexes,
/// and future migrations via [_onUpgrade]. Repositories are handed the
/// opened [Database] and never touch file paths or `openDatabase` directly.
class AppDatabase {
  AppDatabase._();

  static Database? _instance;

  /// Opens (or returns the already-open) database. Safe to call multiple
  /// times - `main()` calls this once and injects the result into
  /// [databaseProvider] via an override.
  static Future<Database> open() async {
    if (_instance != null) return _instance!;
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, DbConstants.dbName);
      _instance = await openDatabase(
        path,
        version: DbConstants.dbVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
      return _instance!;
    } catch (e) {
      throw AppException('Failed to open the local database', e);
    }
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${DbConstants.tableUserProfile} (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        age INTEGER NOT NULL,
        height_cm REAL NOT NULL,
        weight_kg REAL NOT NULL,
        gender TEXT NOT NULL,
        goal TEXT NOT NULL,
        bmi REAL NOT NULL,
        bmi_category TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${DbConstants.tableWorkouts} (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        exercise_name TEXT NOT NULL,
        sets INTEGER,
        reps INTEGER,
        duration_min INTEGER NOT NULL,
        met REAL NOT NULL,
        calories REAL NOT NULL,
        notes TEXT,
        performed_at TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_workouts_performed_at ON ${DbConstants.tableWorkouts} (performed_at)',
    );
    await db.execute(
      'CREATE INDEX idx_workouts_type ON ${DbConstants.tableWorkouts} (type)',
    );

    await db.execute('''
      CREATE TABLE ${DbConstants.tableWeightLogs} (
        id TEXT PRIMARY KEY,
        weight_kg REAL NOT NULL,
        bmi REAL NOT NULL,
        logged_at TEXT NOT NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_weight_logs_logged_at ON ${DbConstants.tableWeightLogs} (logged_at)',
    );

    await db.execute('''
      CREATE TABLE ${DbConstants.tableGoals} (
        id INTEGER PRIMARY KEY,
        daily_calorie_target INTEGER NOT NULL,
        weekly_calorie_target INTEGER NOT NULL,
        daily_workout_target INTEGER NOT NULL,
        weekly_workout_target INTEGER NOT NULL,
        daily_step_target INTEGER NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${DbConstants.tableAchievements} (
        code TEXT PRIMARY KEY,
        unlocked_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${DbConstants.tableStepLogs} (
        date TEXT PRIMARY KEY,
        steps INTEGER NOT NULL,
        sensor_baseline INTEGER NOT NULL,
        last_sensor_value INTEGER NOT NULL
      )
    ''');
  }

  // ignore: unused_element
  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // No migrations yet - this app has only shipped schema version 1.
    // Future versions add `if (oldVersion < N) { ... }` blocks here.
  }
}
