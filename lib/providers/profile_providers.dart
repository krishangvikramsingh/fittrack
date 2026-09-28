import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_profile.dart';
import '../repositories/profile_repository.dart';
import 'core_providers.dart';

/// Holds the user's profile, loading it once on startup. `null` data means
/// "no profile saved yet" (i.e. onboarding hasn't completed), distinct from
/// the loading/error states `AsyncValue` already models.
class ProfileNotifier extends StateNotifier<AsyncValue<UserProfile?>> {
  final ProfileRepository _repo;

  ProfileNotifier(this._repo) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.getProfile());
  }

  Future<void> saveProfile(UserProfile profile) async {
    await _repo.saveProfile(profile);
    state = AsyncValue.data(profile);
  }

  Future<void> refresh() => _load();
}

final profileProvider = StateNotifierProvider<ProfileNotifier, AsyncValue<UserProfile?>>((ref) {
  return ProfileNotifier(ref.watch(profileRepositoryProvider));
});
