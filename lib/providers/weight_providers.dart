import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/weight_log.dart';
import '../repositories/weight_log_repository.dart';
import '../utils/bmi_calculator.dart';
import 'core_providers.dart';
import 'profile_providers.dart';

const _uuid = Uuid();

/// Holds the full weight/BMI history (oldest first), used by the progress
/// charts. Adding an entry also updates the user's profile weight (and
/// recomputed BMI) so the dashboard and onboarding-derived data stay
/// consistent with the latest measurement.
class WeightLogsNotifier extends StateNotifier<AsyncValue<List<WeightLog>>> {
  final WeightLogRepository _repo;
  final Ref _ref;

  WeightLogsNotifier(this._repo, this._ref) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.getAll());
  }

  Future<void> addEntry(double weightKg) async {
    final profile = _ref.read(profileProvider).valueOrNull;
    final bmi = profile == null
        ? 0.0
        : BmiCalculator.calculate(weightKg: weightKg, heightCm: profile.heightCm);

    final entry = WeightLog(id: _uuid.v4(), weightKg: weightKg, bmi: bmi, loggedAt: DateTime.now());
    await _repo.insert(entry);
    await _load();

    if (profile != null) {
      await _ref.read(profileProvider.notifier).saveProfile(
            profile.copyWith(
              weightKg: weightKg,
              bmi: bmi,
              bmiCategory: BmiCalculator.categorize(bmi),
            ),
          );
    }
  }
}

final weightLogsProvider =
    StateNotifierProvider<WeightLogsNotifier, AsyncValue<List<WeightLog>>>((ref) {
  return WeightLogsNotifier(ref.watch(weightLogRepositoryProvider), ref);
});
