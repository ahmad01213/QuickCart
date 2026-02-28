import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/constants/api_constants.dart';
import 'data/datasources/auth_local_datasource.dart';
import 'data/datasources/cart_local_datasource.dart';
import 'data/datasources/onboarding_local_datasource.dart';
import 'data/datasources/product_remote_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/cart_repository_impl.dart';
import 'data/repositories/onboarding_repository_impl.dart';
import 'data/repositories/product_repository_impl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

  final authLocal = AuthLocalDatasourceImpl(prefs);
  final productRemote = ProductRemoteDatasourceImpl(dio);
  final onboardingLocal = OnboardingLocalDatasourceImpl(prefs);

  final authRepository = AuthRepositoryImpl(authLocal);
  final productRepository = ProductRepositoryImpl(productRemote);
  final onboardingRepository = OnboardingRepositoryImpl(onboardingLocal);
  final cartLocal = CartLocalDatasourceImpl(prefs);
  final cartRepository = CartRepositoryImpl(cartLocal);

  runApp(QuickCartApp(
    authRepository: authRepository,
    productRepository: productRepository,
    onboardingRepository: onboardingRepository,
    cartRepository: cartRepository,
  ));
}
