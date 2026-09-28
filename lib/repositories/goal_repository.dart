import 'package:sqflite/sqflite.dart';

import '../models/goals.dart';
import '../utils/app_exception.dart';
import '../utils/constants.dart';

/// Reads and writes the single-row `goals` table.
class GoalRepository {
  final Database _db;

  GoalRepository(this._db);

  Future<Goals> getGoals() async {
    try {
      final rows = await _db.query(
        DbConstants.tableGoals,
        where: 'id = ?',
        whereArgs: [DbConstants.singletonRowId],
        limit: 1,
      );
      if (rows.isEmpty) {
        final defaults = Goals.defaults();
        await saveGoals(defaults);
        return defaults;
      }
      return Goals.fromMap(rows.first);
    } catch (e) {
      throw AppException('Failed to load goals', e);
    }
  }

  Future<void> saveGoals(Goals goals) async {
    try {
      await _db.insert(
        DbConstants.tableGoals,
        {'id': DbConstants.singletonRowId, ...goals.toMap()},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw AppException('Failed to save goals', e);
    }
  }
}
