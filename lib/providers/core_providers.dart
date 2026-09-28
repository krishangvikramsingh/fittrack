import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../repositories/achievement_repository.dart';
import '../repositories/goal_repository.dart';
import '../repositories/profile_repository.dart';
import '../repositories/step_repository.dart';
import '../repositories/weight_log_repository.dart';
import '../repositories/workout_repository.dart';
import '../services/notification_service.dart';
import '../services/pedometer_service.dart';
import '../services/permission_service.dart';

/// Foundational providers for the two things `main()` sets up before
/// `runApp`: SharedPreferences and the sqflite [Database]. Both throw if a
/// screen tries to read them before `main()` overrides them via
/// `ProviderScope(overrides: [...])` - that's intentional, since neither
/// should ever be constructed lazily from inside the widget tree.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in main()');
});

final databaseProvider = Provider<Database>((ref) {
  throw UnimplementedError('databaseProvider must be overridden in main()');
});

// ---------------------------------------------------------------------------
// Repositories - each just wraps the shared Database connection.
// ---------------------------------------------------------------------------

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(ref.watch(databaseProvider)),
);

final workoutRepositoryProvider = Provider<WorkoutRepository>(
  (ref) => WorkoutRepository(ref.watch(databaseProvider)),
);

final weightLogRepositoryProvider = Provider<WeightLogRepository>(
  (ref) => WeightLogRepository(ref.watch(databaseProvider)),
);

final goalRepositoryProvider = Provider<GoalRepository>(
  (ref) => GoalRepository(ref.watch(databaseProvider)),
);

final achievementRepositoryProvider = Provider<AchievementRepository>(
  (ref) => AchievementRepository(ref.watch(databaseProvider)),
);

final stepRepositoryProvider = Provider<StepRepository>(
  (ref) => StepRepository(ref.watch(databaseProvider)),
);

// ---------------------------------------------------------------------------
// Platform services
// ---------------------------------------------------------------------------

final notificationServiceProvider = Provider<NotificationService>((ref) => NotificationService());

final pedometerServiceProvider = Provider<PedometerService>((ref) => PedometerService());

final permissionServiceProvider = Provider<PermissionService>((ref) => PermissionService());
