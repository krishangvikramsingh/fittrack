import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/profile_providers.dart';
import 'providers/settings_providers.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/shell/shell_screen.dart';
import 'utils/theme.dart';

/// The app root: wires up the light/dark theme and decides, based on
/// whether a profile has been saved yet, whether to show onboarding or the
/// main shell.
class FitTrackApp extends ConsumerWidget {
  const FitTrackApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    // Only watched here for the initial-load spinner/error state; which
    // screen to show is gated on `settings.onboardingComplete`, not on
    // whether a profile row exists - see AppSettings.onboardingComplete for
    // why (the profile is written partway *through* onboarding).
    final profileAsync = ref.watch(profileProvider);

    final Widget home;
    if (profileAsync.isLoading) {
      home = const _SplashScreen();
    } else if (profileAsync.hasError) {
      home = _StartupErrorScreen(error: profileAsync.error!);
    } else if (!settings.onboardingComplete) {
      home = const OnboardingScreen();
    } else {
      home = const ShellScreen();
    }

    return MaterialApp(
      title: 'FitTrack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: settings.themeMode,
      home: home,
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class _StartupErrorScreen extends StatelessWidget {
  final Object error;
  const _StartupErrorScreen({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 12),
              Text('Failed to load your data.\n$error', textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
