import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:gowork/services/onboarding_storage.dart';
import 'package:gowork/theme/app_colors.dart';

class OnboardingView extends StatefulWidget {
  final String nextRoute;

  const OnboardingView({super.key, required this.nextRoute});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  final OnboardingStorage _storage = OnboardingStorage();
  int _currentPage = 0;
  bool _isCompleting = false;

  static const List<_OnboardingPageData> _pages = [
    _OnboardingPageData(
      title: 'اكتشف فرصك بثقة',
      description:
          'فرص عمل مناسبة لخبرتك وتخصصك في مكان واحد، مع تجربة بحث مصممة لتقربك من القرار الصحيح.',
      icon: Icons.travel_explore_rounded,
      accent: Color(0xFF2F80ED),
    ),
    _OnboardingPageData(
      title: 'قدّم بذكاء',
      description:
          'تابع الوظائف التي تهمك، راجع التفاصيل بوضوح، وقدّم بخطوات سهلة تمنح ملفك حضورًا أفضل.',
      icon: Icons.rocket_launch_rounded,
      accent: Color(0xFF00A6D6),
    ),
    _OnboardingPageData(
      title: 'مسارك يبدأ من هنا',
      description:
          'من البحث إلى المقابلات ومتابعة الطلبات، مسارك يجمع رحلتك المهنية في تجربة واحدة حديثة.',
      icon: Icons.auto_awesome_rounded,
      accent: Color(0xFF2962FF),
    ),
  ];

  bool get _isLastPage => _currentPage == _pages.length - 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    if (_isCompleting) return;

    setState(() => _isCompleting = true);
    await _storage.markSeen();

    if (!mounted) return;
    context.go(widget.nextRoute);
  }

  void _goToNextPage() {
    if (_isLastPage) {
      _completeOnboarding();
      return;
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 720;
              final horizontalPadding = isWide ? 48.0 : 24.0;
              final contentMaxWidth = isWide ? 920.0 : 460.0;

              return Stack(
                children: [
                  const Positioned.fill(child: _OnboardingBackground()),
                  Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: contentMaxWidth),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                          vertical: 18,
                        ),
                        child: Column(
                          children: [
                            _OnboardingTopBar(
                              canSkip: !_isCompleting,
                              onSkip: _completeOnboarding,
                            ),
                            Expanded(
                              child: PageView.builder(
                                controller: _pageController,
                                itemCount: _pages.length,
                                onPageChanged: (index) {
                                  setState(() => _currentPage = index);
                                },
                                itemBuilder: (context, index) {
                                  return _OnboardingPage(
                                    data: _pages[index],
                                    isWide: isWide,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 12),
                            _PageIndicator(
                              pageCount: _pages.length,
                              currentPage: _currentPage,
                            ),
                            const SizedBox(height: 22),
                            _OnboardingActions(
                              isLastPage: _isLastPage,
                              isLoading: _isCompleting,
                              onNext: _goToNextPage,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  final String title;
  final String description;
  final IconData icon;
  final Color accent;

  const _OnboardingPageData({
    required this.title,
    required this.description,
    required this.icon,
    required this.accent,
  });
}

class _OnboardingTopBar extends StatelessWidget {
  final bool canSkip;
  final VoidCallback onSkip;

  const _OnboardingTopBar({required this.canSkip, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          'assets/logo_cropped.png',
          width: 52,
          height: 52,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.work_outline_rounded,
            color: AppColors.primary,
            size: 34,
          ),
        ).animate().fade(duration: 500.ms).scale(
          begin: const Offset(0.88, 0.88),
          duration: 600.ms,
          curve: Curves.easeOutBack,
        ),
        const Spacer(),
        TextButton(
          onPressed: canSkip ? onSkip : null,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
          child: const Text(
            'تخطي',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingPageData data;
  final bool isWide;

  const _OnboardingPage({required this.data, required this.isWide});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final visual = _OnboardingVisual(data: data)
        .animate(key: ValueKey(data.title))
        .fade(duration: 520.ms)
        .slideY(begin: 0.08, end: 0, duration: 520.ms, curve: Curves.easeOut);

    final copy = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: isWide
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Text(
          data.title,
          textAlign: isWide ? TextAlign.start : TextAlign.center,
          style: textTheme.displaySmall?.copyWith(
            fontSize: isWide ? 34 : 28,
            height: 1.22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          data.description,
          textAlign: isWide ? TextAlign.start : TextAlign.center,
          style: textTheme.bodyLarge?.copyWith(
            height: 1.75,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ).animate(key: ValueKey('${data.title}-copy')).fade(
      delay: 140.ms,
      duration: 520.ms,
    ).slideY(begin: 0.1, end: 0, duration: 520.ms, curve: Curves.easeOut);

    if (isWide) {
      return Row(
        children: [
          Expanded(child: copy),
          const SizedBox(width: 36),
          Expanded(child: visual),
        ],
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(child: visual),
        const SizedBox(height: 34),
        copy,
      ],
    );
  }
}

class _OnboardingVisual extends StatelessWidget {
  final _OnboardingPageData data;

  const _OnboardingVisual({required this.data});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(child: _JourneyTrack(color: data.accent)),
          Positioned(
            left: 54,
            top: 72,
            child: Transform.rotate(
              angle: -math.pi / 9,
              child: _DecorativeLine(color: data.accent),
            ),
          ),
          Positioned(
            right: 50,
            bottom: 76,
            child: Transform.rotate(
              angle: math.pi / 11,
              child: _DecorativeLine(
                color: const Color(0xFF00A6D6),
                width: 76,
              ),
            ),
          ),
          Container(
            width: 176,
            height: 176,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(36),
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  data.accent.withValues(alpha: 0.18),
                  AppColors.primary.withValues(alpha: 0.08),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: data.accent.withValues(alpha: 0.18),
                  blurRadius: 34,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 108,
                height: 108,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: data.accent.withValues(alpha: 0.10),
                  ),
                ),
                child: Icon(data.icon, color: data.accent, size: 56),
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
              .moveY(
                begin: -5,
                end: 5,
                duration: 1800.ms,
                curve: Curves.easeInOut,
              ),
        ],
      ),
    );
  }
}

class _JourneyTrack extends StatelessWidget {
  final Color color;

  const _JourneyTrack({required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _JourneyTrackPainter(color),
    );
  }
}

class _JourneyTrackPainter extends CustomPainter {
  final Color color;

  const _JourneyTrackPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final primaryPaint = Paint()
      ..color = color.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final secondaryPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.09)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final mainPath = Path()
      ..moveTo(size.width * 0.15, size.height * 0.66)
      ..cubicTo(
        size.width * 0.28,
        size.height * 0.30,
        size.width * 0.68,
        size.height * 0.82,
        size.width * 0.85,
        size.height * 0.38,
      );

    final secondaryPath = Path()
      ..moveTo(size.width * 0.20, size.height * 0.30)
      ..cubicTo(
        size.width * 0.42,
        size.height * 0.16,
        size.width * 0.62,
        size.height * 0.36,
        size.width * 0.78,
        size.height * 0.22,
      );

    canvas.drawPath(mainPath, primaryPaint);
    canvas.drawPath(secondaryPath, secondaryPaint);

    final markerPaint = Paint()..color = color.withValues(alpha: 0.30);
    for (final point in [
      Offset(size.width * 0.22, size.height * 0.60),
      Offset(size.width * 0.76, size.height * 0.42),
    ]) {
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: point, width: 18, height: 8),
        const Radius.circular(99),
      );
      canvas.drawRRect(rect, markerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _JourneyTrackPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _DecorativeLine extends StatelessWidget {
  final Color color;
  final double width;

  const _DecorativeLine({required this.color, this.width = 54});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 6,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  final int pageCount;
  final int currentPage;

  const _PageIndicator({required this.pageCount, required this.currentPage});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pageCount, (index) {
        final isActive = index == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOut,
          width: isActive ? 28 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }),
    );
  }
}

class _OnboardingActions extends StatelessWidget {
  final bool isLastPage;
  final bool isLoading;
  final VoidCallback onNext;

  const _OnboardingActions({
    required this.isLastPage,
    required this.isLoading,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onNext,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: isLoading
              ? const SizedBox(
                  key: ValueKey('loading'),
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Row(
                  key: ValueKey(isLastPage),
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isLastPage ? 'ابدأ الآن' : 'التالي',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.arrow_back_rounded, size: 22),
                  ],
                ),
        ),
      ),
    );
  }
}

class _OnboardingBackground extends StatelessWidget {
  const _OnboardingBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            const Color(0xFFEBF5FF),
            Colors.white,
            AppColors.primary.withValues(alpha: 0.07),
          ],
        ),
      ),
      child: Stack(
        children: const [
          Positioned(
            top: 72,
            right: 0,
            child: _BackgroundLine(width: 112, color: AppColors.primary),
          ),
          Positioned(
            bottom: 96,
            left: 0,
            child: _BackgroundLine(width: 148, color: Color(0xFF00A6D6)),
          ),
        ],
      ),
    );
  }
}

class _BackgroundLine extends StatelessWidget {
  final double width;
  final Color color;

  const _BackgroundLine({required this.width, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 3,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}
