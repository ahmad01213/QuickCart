import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._local);

  final AuthLocalDatasource _local;

  static const String _validOtp = '0000';

  @override
  Future<bool> loginWithEmail(String email, String password) async {
    await _local.setLoginMethod('email');
    await _local.setLoggedIn(true);
    return true;
  }

  @override
  Future<bool> loginWithPhone(String phone, String countryCode) async {
    await _local.setLoginMethod('phone');
    return true;
  }

  @override
  Future<bool> verifyOtp(String code) async {
    if (code != _validOtp) return false;
    await _local.setLoggedIn(true);
    return true;
  }

  @override
  Future<bool> isLoggedIn() async {
    return _local.getLoggedIn();
  }

  @override
  Future<void> logout() async {
    await _local.clear();
  }

  @override
  Future<void> saveSession() async {
    await _local.setLoggedIn(true);
  }
}
