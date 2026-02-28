import '../../domain/entities/onboarding_slide.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/onboarding_local_datasource.dart';
import '../datasources/onboarding_slides_source.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  OnboardingRepositoryImpl(this._local);

  final OnboardingLocalDatasource _local;

  @override
  Future<List<OnboardingSlide>> getSlides() async {
    return OnboardingSlidesSource.slides;
  }

  @override
  Future<bool> isOnboardingCompleted() async {
    return _local.isOnboardingCompleted();
  }

  @override
  Future<void> setOnboardingCompleted() async {
    await _local.setOnboardingCompleted();
  }
}
