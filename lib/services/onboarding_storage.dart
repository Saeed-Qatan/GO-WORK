import 'package:gowork/utils/local_storage.dart';

class OnboardingStorage {
  static const String hasSeenSeekerOnboardingKey =
      'has_seen_seeker_onboarding';

  final LocalStorage _storage;

  OnboardingStorage({LocalStorage? storage})
    : _storage = storage ?? LocalStorage();

  Future<bool> hasSeenOnboarding() async {
    return await _storage.getBool(hasSeenSeekerOnboardingKey) ?? false;
  }

  Future<void> markSeen() {
    return _storage.saveBool(hasSeenSeekerOnboardingKey, true);
  }
}
