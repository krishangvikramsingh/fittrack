import 'package:sqflite/sqflite.dart';

import '../models/weight_log.dart';
import '../utils/app_exception.dart';
import '../utils/constants.dart';

/// CRUD over the `weight_logs` table, which feeds the weight-trend and
/// BMI-history charts.
class WeightLogRepository {
  final Database _db;

  WeightLogRepository(this._db);

  Future<List<WeightLog>> getAll() async {
    try {
      final rows = await _db.query(
        DbConstants.tableWeightLogs,
        orderBy: 'logged_at ASC',
      );
      return rows.map(WeightLog.fromMap).toList();
    } catch (e) {
      throw AppException('Failed to load weight history', e);
    }
  }

  Future<void> insert(WeightLog log) async {
    try {
      await _db.insert(DbConstants.tableWeightLogs, log.toMap());
    } catch (e) {
      throw AppException('Failed to save the weight entry', e);
    }
  }

  Future<void> delete(String id) async {
    try {
      await _db.delete(
        DbConstants.tableWeightLogs,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw AppException('Failed to delete the weight entry', e);
    }
  }
}
