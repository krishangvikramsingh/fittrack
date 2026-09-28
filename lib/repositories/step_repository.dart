import 'package:sqflite/sqflite.dart';

import '../models/step_log.dart';
import '../utils/app_exception.dart';
import '../utils/constants.dart';

/// Persists per-day step-counter state so today's count survives an app
/// restart, and past days remain available for the "10k steps" achievement.
class StepRepository {
  final Database _db;

  StepRepository(this._db);

  Future<StepLog?> getByDate(String date) async {
    try {
      final rows = await _db.query(
        DbConstants.tableStepLogs,
        where: 'date = ?',
        whereArgs: [date],
        limit: 1,
      );
      if (rows.isEmpty) return null;
      return StepLog.fromMap(rows.first);
    } catch (e) {
      throw AppException('Failed to load step data', e);
    }
  }

  Future<void> upsert(StepLog log) async {
    try {
      await _db.insert(
        DbConstants.tableStepLogs,
        log.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw AppException('Failed to save step data', e);
    }
  }

  /// Highest single-day step count ever recorded - used for the "10k steps
  /// in a day" achievement.
  Future<int> maxStepsInADay() async {
    try {
      final result = await _db.rawQuery(
        'SELECT COALESCE(MAX(steps), 0) AS maxSteps FROM ${DbConstants.tableStepLogs}',
      );
      return (result.first['maxSteps'] as num).toInt();
    } catch (e) {
      throw AppException('Failed to compute max daily steps', e);
    }
  }
}
