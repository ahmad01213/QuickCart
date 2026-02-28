import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/onboarding_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required AuthRepository authRepository,
    required OnboardingRepository onboardingRepository,
  })  : _authRepository = authRepository,
        _onboardingRepository = onboardingRepository,
        super(const AuthState());

  final AuthRepository _authRepository;
  final OnboardingRepository _onboardingRepository;

  Future<void> init() async {
    final isLoggedIn = await _authRepository.isLoggedIn();
    final isOnboardingCompleted =
        await _onboardingRepository.isOnboardingCompleted();
    emit(state.copyWith(
      isInitialized: true,
      isOnboardingCompleted: isOnboardingCompleted,
      isLoggedIn: isLoggedIn,
    ));
  }

  Future<void> completeOnboarding() async {
    await _onboardingRepository.setOnboardingCompleted();
    emit(state.copyWith(isOnboardingCompleted: true));
  }

  Future<void> loginWithEmail(String email, String password) async {
    await _authRepository.loginWithEmail(email, password);
    await _authRepository.saveSession();
    emit(state.copyWith(isLoggedIn: true));
  }

  Future<void> loginWithPhone(String phone, String countryCode) async {
    await _authRepository.loginWithPhone(phone, countryCode);
  }

  Future<bool> verifyOtp(String code) async {
    final ok = await _authRepository.verifyOtp(code);
    if (ok) {
      await _authRepository.saveSession();
      emit(state.copyWith(isLoggedIn: true));
    }
    return ok;
  }

  void setLoggedIn() {
    emit(state.copyWith(isLoggedIn: true));
  }

  Future<void> logout() async {
    await _authRepository.logout();
    emit(state.copyWith(isLoggedIn: false));
  }
}
