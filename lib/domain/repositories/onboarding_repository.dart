import '../entities/onboarding_slide.dart';

abstract class OnboardingRepository {
  Future<List<OnboardingSlide>> getSlides();
  Future<bool> isOnboardingCompleted();
  Future<void> setOnboardingCompleted();
}
