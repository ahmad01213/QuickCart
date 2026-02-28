import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/storage_keys.dart';

abstract class AuthLocalDatasource {
  Future<void> setLoggedIn(bool value);
  Future<bool> getLoggedIn();
  Future<void> setLoginMethod(String method);
  Future<void> clear();
}

class AuthLocalDatasourceImpl implements AuthLocalDatasource {
  AuthLocalDatasourceImpl(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<void> setLoggedIn(bool value) async {
    await _prefs.setBool(StorageKeys.isLoggedIn, value);
  }

  @override
  Future<bool> getLoggedIn() async {
    return _prefs.getBool(StorageKeys.isLoggedIn) ?? false;
  }

  @override
  Future<void> setLoginMethod(String method) async {
    await _prefs.setString(StorageKeys.loginMethod, method);
  }

  @override
  Future<void> clear() async {
    await _prefs.remove(StorageKeys.isLoggedIn);
    await _prefs.remove(StorageKeys.loginMethod);
  }
}
