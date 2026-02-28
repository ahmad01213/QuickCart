import 'package:equatable/equatable.dart';

class AuthState extends Equatable {
  const AuthState({
    this.isInitialized = false,
    this.isOnboardingCompleted = false,
    this.isLoggedIn = false,
  });

  final bool isInitialized;
  final bool isOnboardingCompleted;
  final bool isLoggedIn;

  AuthState copyWith({
    bool? isInitialized,
    bool? isOnboardingCompleted,
    bool? isLoggedIn,
  }) {
    return AuthState(
      isInitialized: isInitialized ?? this.isInitialized,
      isOnboardingCompleted: isOnboardingCompleted ?? this.isOnboardingCompleted,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }

  @override
  List<Object?> get props => [isInitialized, isOnboardingCompleted, isLoggedIn];
}
