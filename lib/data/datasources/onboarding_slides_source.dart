import '../../domain/entities/onboarding_slide.dart';

/// Onboarding slides; images are loaded from assets/images/
class OnboardingSlidesSource {
  OnboardingSlidesSource._();

  static const List<OnboardingSlide> slides = [
    OnboardingSlide(
      title: 'متجر أونلاين',
      subtitle: 'تسوّق معنا',
      description: 'تصفّح آلاف المنتجات من مختلف الفئات وأضف ما يعجبك إلى السلة في خطوات بسيطة.',
      imageUrl: 'assets/images/1.png',
    ),
    OnboardingSlide(
      title: 'توصيل آمن',
      subtitle: 'فريقنا الأفضل',
      description: 'نوصّل طلبك إلى باب منزلك بأمان وسرعة. ابدأ التسوق الآن.',
      imageUrl: 'assets/images/2.png',
    ),
    OnboardingSlide(
      title: 'خصومات واسترجاع نقدي',
      description: 'استمتع بعروض وتخفيضات على أفضل المنتجات ووفر أكثر مع كل طلب.',
      imageUrl: 'assets/images/3.png',
    ),
  ];
}
