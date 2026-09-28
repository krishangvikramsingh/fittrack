import 'package:sqflite/sqflite.dart';

import '../utils/app_exception.dart';
import '../utils/constants.dart';

/// Persists which achievement codes have been unlocked. Badge *definitions*
/// live in code (models/achievement.dart) - this table only records the
/// unlock event.
class AchievementRepository {
  final Database _db;

  AchievementRepository(this._db);

  /// Returns `{code: unlockedAt}` for every unlocked badge.
  Future<Map<String, DateTime>> getUnlocked() async {
    try {
      final rows = await _db.query(DbConstants.tableAchievements);
      return {
        for (final row in rows)
          row['code']! as String: DateTime.parse(row['unlocked_at']! as String),
      };
    } catch (e) {
      throw AppException('Failed to load achievements', e);
    }
  }

  Future<void> unlock(String code, DateTime unlockedAt) async {
    try {
      await _db.insert(
        DbConstants.tableAchievements,
        {'code': code, 'unlocked_at': unlockedAt.toIso8601String()},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    } catch (e) {
      throw AppException('Failed to unlock achievement', e);
    }
  }
}
