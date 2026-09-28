import 'package:sqflite/sqflite.dart';

import '../models/user_profile.dart';
import '../utils/app_exception.dart';
import '../utils/constants.dart';

/// Reads and writes the single-row `user_profile` table.
class ProfileRepository {
  final Database _db;

  ProfileRepository(this._db);

  Future<UserProfile?> getProfile() async {
    try {
      final rows = await _db.query(
        DbConstants.tableUserProfile,
        where: 'id = ?',
        whereArgs: [DbConstants.singletonRowId],
        limit: 1,
      );
      if (rows.isEmpty) return null;
      return UserProfile.fromMap(rows.first);
    } catch (e) {
      throw AppException('Failed to load the user profile', e);
    }
  }

  Future<void> saveProfile(UserProfile profile) async {
    try {
      await _db.insert(
        DbConstants.tableUserProfile,
        {'id': DbConstants.singletonRowId, ...profile.toMap()},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw AppException('Failed to save the user profile', e);
    }
  }
}
