import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/app_database.dart';
import 'providers/core_providers.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // These two are awaited up front (rather than lazily created inside a
  // provider) because the whole app depends on them being ready before the
  // first frame - see core_providers.dart for why the providers themselves
  // just throw if read before this override is in place.
  final prefs = await SharedPreferences.getInstance();
  final database = await AppDatabase.open();

  final notificationService = NotificationService();
  try {
    await notificationService.init();
  } catch (_) {
    // Notifications are a nice-to-have; a platform failure here (e.g. an
    // unsupported OEM ROM) shouldn't block the rest of the app from running.
  }

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        databaseProvider.overrideWithValue(database),
        notificationServiceProvider.overrideWithValue(notificationService),
      ],
      child: const FitTrackApp(),
    ),
  );
}
