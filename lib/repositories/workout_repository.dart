import 'package:sqflite/sqflite.dart';

import '../models/workout.dart';
import '../utils/app_exception.dart';
import '../utils/constants.dart';

/// CRUD and aggregate queries over the `workouts` table.
class WorkoutRepository {
  final Database _db;

  WorkoutRepository(this._db);

  Future<List<Workout>> getAll() async {
    try {
      final rows = await _db.query(
        DbConstants.tableWorkouts,
        orderBy: 'performed_at DESC',
      );
      return rows.map(Workout.fromMap).toList();
    } catch (e) {
      throw AppException('Failed to load workouts', e);
    }
  }

  Future<void> insert(Workout workout) async {
    try {
      await _db.insert(DbConstants.tableWorkouts, workout.toMap());
    } catch (e) {
      throw AppException('Failed to save the workout', e);
    }
  }

  Future<void> update(Workout workout) async {
    try {
      await _db.update(
        DbConstants.tableWorkouts,
        workout.toMap(),
        where: 'id = ?',
        whereArgs: [workout.id],
      );
    } catch (e) {
      throw AppException('Failed to update the workout', e);
    }
  }

  Future<void> delete(String id) async {
    try {
      await _db.delete(
        DbConstants.tableWorkouts,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw AppException('Failed to delete the workout', e);
    }
  }

  /// Total calories ever logged - used for the "5,000 kcal burned" badge.
  Future<double> totalCaloriesBurned() async {
    try {
      final result = await _db.rawQuery(
        'SELECT COALESCE(SUM(calories), 0) AS total FROM ${DbConstants.tableWorkouts}',
      );
      return (result.first['total'] as num).toDouble();
    } catch (e) {
      throw AppException('Failed to compute total calories burned', e);
    }
  }
}
