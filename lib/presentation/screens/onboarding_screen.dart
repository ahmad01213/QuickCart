import 'package:flutter/material.dart';

import '../../domain/entities/onboarding_slide.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../widgets/animated_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    required this.onboardingRepository,
    required this.onComplete,
  });

  final OnboardingRepository onboardingRepository;
  final VoidCallback onComplete;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  late List<OnboardingSlide> _slides;
  double _currentPage = 0;
  bool _slidesLoaded = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(_onPageChanged);
    _loadSlides();
  }

  void _onPageChanged() {
    if (_pageController.hasClients && mounted) {
      setState(() => _currentPage = _pageController.page ?? 0);
    }
  }

  Future<void> _loadSlides() async {
    final slides = await widget.onboardingRepository.getSlides();
    if (mounted) {
      setState(() {
        _slides = slides;
        _slidesLoaded = true;
      });
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await widget.onboardingRepository.setOnboardingCompleted();
    if (mounted) widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    if (!_slidesLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isLast = _currentPage >= _slides.length - 1;
    final primary = Theme.of(context).colorScheme.primary;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              Container(color: Colors.white),
              _CurvedPrimaryBackground(primaryColor: primary),
              Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: _finish,
                      child: Text(
                        'تخطي',
                        style: TextStyle(
                          color: primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _slides.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return _OnboardingPage(
                          slide: _slides[index],
                          index: index,
                          pageController: _pageController,
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: AnimatedPageIndicator(
                    pageCount: _slides.length,
                    currentPage: _currentPage,
                  ),
                ),
                if (isLast)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _finish,
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('إنشاء حساب'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: _finish,
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: primary,
                              side: BorderSide(color: primary),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('تسجيل الدخول'),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  const SizedBox(height: 24),
              ],
            ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CurvedPrimaryBackground extends StatelessWidget {
  const _CurvedPrimaryBackground({required this.primaryColor});

  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Positioned.fill(
      child: CustomPaint(
        painter: _CurvedBackgroundPainter(color: primaryColor),
        size: size,
      ),
    );
  }
}

class _CurvedBackgroundPainter extends CustomPainter {
  _CurvedBackgroundPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.14)
      ..style = PaintingStyle.fill;

    void drawCurvedBlob(Offset center, double radiusX, double radiusY) {
      final rect = Rect.fromCenter(
        center: center,
        width: radiusX * 2,
        height: radiusY * 2,
      );
      canvas.drawOval(rect, paint);
    }

    drawCurvedBlob(const Offset(-30, 60), 140, 120);
    drawCurvedBlob(Offset(size.width + 40, 40), 160, 140);
    drawCurvedBlob(Offset(-40, size.height + 30), 150, 140);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _OnboardingPage extends StatefulWidget {
  const _OnboardingPage({
    required this.slide,
    required this.index,
    required this.pageController,
  });

  final OnboardingSlide slide;
  final int index;
  final PageController pageController;

  @override
  State<_OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<_OnboardingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _scaleAnim = Tween<double>(begin: 0.96, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return AnimatedBuilder(
      animation: widget.pageController,
      builder: (context, _) {
        final page = widget.pageController.hasClients
            ? (widget.pageController.page ?? widget.index.toDouble())
            : widget.index.toDouble();
        final offset = page - widget.index;
        final opacity = (1 - offset.abs().clamp(0.0, 1.0)).clamp(0.3, 1.0);
        final scale = (1 - (offset.abs() * 0.12)).clamp(0.88, 1.0);
        final isFirstSlide = widget.index == 0;
        final effectiveFade = isFirstSlide ? 1.0 : _fadeAnim.value;
        final effectiveScale = isFirstSlide ? 1.0 : _scaleAnim.value;

        return Opacity(
          opacity: opacity * effectiveFade,
          child: Transform.scale(
            scale: effectiveScale * scale,
            child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.slide.title,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: primary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      if (widget.slide.subtitle != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          widget.slide.subtitle!,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: const Color(0xFF374151),
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 24),
                      AspectRatio(
                        aspectRatio: 4 / 3,
                        child: _buildSlideImage(context, widget.slide.imageUrl),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        widget.slide.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF6B7280),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
          ),
        );
      },
    );
  }

  Widget _buildSlideImage(BuildContext context, String imageUrl) {
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.grey.shade200,
          child: Icon(
            Icons.image_not_supported_rounded,
            size: 48,
            color: Colors.grey.shade400,
          ),
        ),
      );
    }
    return Image.network(
      imageUrl,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey.shade100,
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      (loadingProgress.expectedTotalBytes ?? 1)
                  : null,
              strokeWidth: 2,
            ),
          ),
        );
      },
      errorBuilder: (_, __, ___) => Container(
        color: Colors.grey.shade200,
        child: Icon(
          Icons.image_not_supported_rounded,
          size: 48,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }
}
