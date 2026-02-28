import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/storage_keys.dart';

abstract class OnboardingLocalDatasource {
  Future<bool> isOnboardingCompleted();
  Future<void> setOnboardingCompleted();
}

class OnboardingLocalDatasourceImpl implements OnboardingLocalDatasource {
  OnboardingLocalDatasourceImpl(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<bool> isOnboardingCompleted() async {
    return _prefs.getBool(StorageKeys.onboardingCompleted) ?? false;
  }

  @override
  Future<void> setOnboardingCompleted() async {
    await _prefs.setBool(StorageKeys.onboardingCompleted, true);
  }
}
