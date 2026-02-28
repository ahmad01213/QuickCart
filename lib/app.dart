import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/cart_repository.dart';
import 'domain/repositories/onboarding_repository.dart';
import 'domain/repositories/product_repository.dart';
import 'presentation/cubit/auth/auth_cubit.dart';
import 'presentation/cubit/auth/auth_state.dart';
import 'presentation/cubit/cart/cart_cubit.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/onboarding_screen.dart';

class QuickCartApp extends StatelessWidget {
  const QuickCartApp({
    super.key,
    required this.authRepository,
    required this.productRepository,
    required this.onboardingRepository,
    required this.cartRepository,
  });

  final AuthRepository authRepository;
  final ProductRepository productRepository;
  final OnboardingRepository onboardingRepository;
  final CartRepository cartRepository;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthCubit(
            authRepository: authRepository,
            onboardingRepository: onboardingRepository,
          )..init(),
        ),
        BlocProvider(
          create: (_) => CartCubit(cartRepository)..loadCart(),
        ),
      ],
      child: MaterialApp(
        title: 'كويك كارت',
        theme: AppTheme.light,
        debugShowCheckedModeBanner: false,
        home: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, authState) {
            if (!authState.isInitialized) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.03),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    )),
                    child: child,
                  ),
                );
              },
              child: _authHome(context, authState),
            );
          },
        ),
      ),
    );
  }

  Widget _authHome(BuildContext context, AuthState authState) {
    if (!authState.isOnboardingCompleted) {
      return KeyedSubtree(
        key: const ValueKey('onboarding'),
        child: OnboardingScreen(
          onboardingRepository: onboardingRepository,
          onComplete: () => context.read<AuthCubit>().completeOnboarding(),
        ),
      );
    }
    if (authState.isLoggedIn) {
      return KeyedSubtree(
        key: const ValueKey('home'),
        child: HomeScreen(
          productRepository: productRepository,
          authRepository: authRepository,
        ),
      );
    }
    return KeyedSubtree(
      key: const ValueKey('login'),
      child: LoginScreen(
        authRepository: authRepository,
        onLoginSuccess: () => context.read<AuthCubit>().setLoggedIn(),
      ),
    );
  }
}
