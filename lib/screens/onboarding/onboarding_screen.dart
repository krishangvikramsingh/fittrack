import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/goals.dart';
import '../../models/user_profile.dart';
import '../../providers/goal_providers.dart';
import '../../providers/profile_providers.dart';
import '../../providers/settings_providers.dart';
import '../../providers/weight_providers.dart';
import '../../services/permission_service.dart';
import '../../utils/bmi_calculator.dart';
import '../../utils/constants.dart';
import 'widgets/bmi_result_card.dart';
import 'widgets/body_metrics_page.dart';
import 'widgets/onboarding_progress_dots.dart';
import 'widgets/personal_info_page.dart';
import 'widgets/welcome_page.dart';

/// First-run flow: collects the user's profile, computes their starting
/// BMI, and writes the profile, first weight log and default goals in one
/// go before handing off to [ShellScreen].
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _pageCount = 4;

  final _pageController = PageController();
  final _personalInfoFormKey = GlobalKey<FormState>();
  final _bodyMetricsFormKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  int _currentPage = 0;
  Gender? _gender;
  FitnessGoal? _goal;
  bool _isSaving = false;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  double get _bmi {
    final height = double.tryParse(_heightController.text) ?? 0;
    final weight = double.tryParse(_weightController.text) ?? 0;
    return BmiCalculator.calculate(weightKg: weight, heightCm: height);
  }

  bool get _canGoNext {
    switch (_currentPage) {
      case 0:
        return true;
      case 1:
        return _gender != null;
      case 2:
        return _goal != null;
      default:
        return true;
    }
  }

  void _goToNextPage() {
    if (_currentPage == 1 && !(_personalInfoFormKey.currentState?.validate() ?? false)) {
      return;
    }
    if (_currentPage == 2 && !(_bodyMetricsFormKey.currentState?.validate() ?? false)) {
      return;
    }
    if (!_canGoNext) return;
    _pageController.nextPage(duration: AppDurations.fadeIn, curve: Curves.easeOut);
  }

  void _goToPreviousPage() {
    _pageController.previousPage(duration: AppDurations.fadeIn, curve: Curves.easeOut);
  }

  Future<void> _finishOnboarding() async {
    setState(() => _isSaving = true);
    try {
      final now = DateTime.now();
      final bmi = _bmi;
      final profile = UserProfile(
        name: _nameController.text.trim(),
        age: int.parse(_ageController.text),
        heightCm: double.parse(_heightController.text),
        weightKg: double.parse(_weightController.text),
        gender: _gender!,
        goal: _goal!,
        bmi: bmi,
        bmiCategory: BmiCalculator.categorize(bmi),
        createdAt: now,
        updatedAt: now,
      );

      await ref.read(profileProvider.notifier).saveProfile(profile);
      await ref.read(weightLogsProvider.notifier).addEntry(profile.weightKg);
      await ref.read(goalsProvider.notifier).updateGoals(Goals.defaults());

      // Best-effort: onboarding shouldn't fail just because a permission
      // prompt was dismissed.
      try {
        await PermissionService().requestActivityRecognition();
      } catch (_) {
        // Ignored - the dashboard shows a graceful fallback state instead.
      }

      // Must be the last write: this flips app.dart's reactive gate from
      // OnboardingScreen to ShellScreen, which disposes this screen's
      // State - nothing below this line may touch `ref` again.
      await ref.read(settingsProvider.notifier).completeOnboarding();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.md),
            OnboardingProgressDots(pageCount: _pageCount, currentPage: _currentPage),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  const WelcomePage(),
                  Form(
                    key: _personalInfoFormKey,
                    child: PersonalInfoPage(
                      nameController: _nameController,
                      ageController: _ageController,
                      gender: _gender,
                      onGenderChanged: (g) => setState(() => _gender = g),
                    ),
                  ),
                  Form(
                    key: _bodyMetricsFormKey,
                    child: BodyMetricsPage(
                      heightController: _heightController,
                      weightController: _weightController,
                      goal: _goal,
                      onGoalChanged: (g) => setState(() => _goal = g),
                    ),
                  ),
                  _ReviewPage(bmi: _bmi, category: BmiCalculator.categorize(_bmi)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSaving ? null : _goToPreviousPage,
                        child: const Text('Back'),
                      ),
                    ),
                  if (_currentPage > 0) const SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isSaving
                          ? null
                          : (_currentPage == _pageCount - 1 ? _finishOnboarding : _goToNextPage),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2.5),
                            )
                          : Text(_currentPage == _pageCount - 1 ? 'Get Started' : 'Next'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewPage extends StatelessWidget {
  final double bmi;
  final BmiCategory category;

  const _ReviewPage({required this.bmi, required this.category});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("You're all set", style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.sm),
          Text(
            "Here's where you're starting from - we'll track your progress from here.",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          BmiResultCard(bmi: bmi, category: category),
        ],
      ),
    );
  }
}
