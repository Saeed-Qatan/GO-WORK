import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:gowork/utils/local_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:gowork/routing/app_router.dart';
import 'package:gowork/repository/profile_repository.dart';
import 'package:gowork/services/onboarding_storage.dart';
import 'package:gowork/services/notification_topic_service.dart';
import 'package:gowork/theme/app_colors.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with TickerProviderStateMixin {
  final OnboardingStorage _onboardingStorage = OnboardingStorage();
  final NotificationTopicService _notificationTopicService =
      NotificationTopicService();

  // Animation Controllers
  late AnimationController _fadeScaleController;
  late AnimationController _glowController;
  late AnimationController _progressController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _progressAnimation;

  // Text Animation States
  double _textOpacity1 = 0.0;
  double _textOpacity2 = 0.0;

  // Redirection sync states
  String? _targetRoute;
  bool _isProgressComplete = false;

  @override
  void initState() {
    super.initState();

    // 1. Setup Animation Controllers (before first frame)
    _fadeScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // 2. Setup Animations
    _fadeAnimation = CurvedAnimation(
      parent: _fadeScaleController,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _fadeScaleController, curve: Curves.easeOutBack),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    // 3. Start visible animations & session check AFTER first frame is painted.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Signal the native splash to begin its exit transition.
      FlutterNativeSplash.remove();

      // Start session check IMMEDIATELY while the native splash is
      // playing its exit animation (~500ms on Android 12+).
      _checkSession();

      // Delay visual animations until the native splash exit animation
      // finishes. This guarantees the user always sees the progress bar
      // start from 0% — not from the middle.
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;

        _fadeScaleController.forward();
        _progressController.forward().then((_) {
          if (mounted) {
            setState(() => _isProgressComplete = true);
            _checkAndNavigate();
          }
        });

        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) setState(() => _textOpacity1 = 1.0);
        });
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) setState(() => _textOpacity2 = 1.0);
        });
      });
    });
  }

  @override
  void dispose() {
    _fadeScaleController.dispose();
    _glowController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _checkSession() async {

    final token = await LocalStorage().getString('token');

    String nextRoute = AppRoutes.login;

    if (token != null && token.isNotEmpty) {
      try {
        final profile = await ProfileRepository().getUserProfile();
        await _notificationTopicService.subscribeUserTopics(
          categoryId: profile.categoryId,
        );
        nextRoute = AppRoutes.home;
      } catch (e) {
        await LocalStorage().clearAuth();
        await _notificationTopicService.subscribeUserTopics(categoryId: null);
        nextRoute = AppRoutes.login;
      }
    } else {
      final cachedCategoryId = await LocalStorage().getString('categoryId');
      await _notificationTopicService.subscribeUserTopics(
        categoryId: cachedCategoryId,
      );
      nextRoute = AppRoutes.login;
    }

    final hasSeenOnboarding = await _onboardingStorage.hasSeenOnboarding();

    if (!hasSeenOnboarding) {
      nextRoute = Uri(
        path: AppRoutes.onboarding,
        queryParameters: {'next': nextRoute},
      ).toString();
    }

    if (mounted) {
      setState(() => _targetRoute = nextRoute);
      _checkAndNavigate();
    }
  }

  void _checkAndNavigate() {
    if (_isProgressComplete && _targetRoute != null) {
      context.go(_targetRoute!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double logoContainerSize = (size.width * 0.35).clamp(120.0, 160.0);
    final double titleFontSize = (size.width * 0.09).clamp(32.0, 42.0);
    final double subtitleFontSize = (size.width * 0.04).clamp(14.0, 18.0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Large transparent background circles & elements in primary color
          Positioned(
            left: -size.width * 0.2,
            top: size.height * 0.15,
            child: Opacity(
              opacity: 0.05,
              child: Container(
                width: size.width * 0.7,
                height: size.width * 0.7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 1.2),
                ),
              ),
            ),
          ),
          Positioned(
            right: -size.width * 0.3,
            bottom: size.height * 0.2,
            child: Opacity(
              opacity: 0.04,
              child: Container(
                width: size.width * 0.9,
                height: size.width * 0.9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
          ),

          // Minor decorative plus/cross/dots with low opacity in primary color
          Positioned(
            left: size.width * 0.15,
            top: size.height * 0.25,
            child: Opacity(
              opacity: 0.08,
              child: const Icon(Icons.add, color: AppColors.primary, size: 20),
            ),
          ),
          Positioned(
            right: size.width * 0.2,
            top: size.height * 0.3,
            child: Opacity(
              opacity: 0.06,
              child: Transform.rotate(
                angle: 0.785, // 45 degrees for 'x' cross look
                child: const Icon(
                  Icons.add,
                  color: AppColors.primary,
                  size: 16,
                ),
              ),
            ),
          ),
          Positioned(
            left: size.width * 0.25,
            bottom: size.height * 0.3,
            child: Opacity(
              opacity: 0.08,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Positioned(
            right: size.width * 0.15,
            bottom: size.height * 0.25,
            child: Opacity(
              opacity: 0.08,
              child: const Icon(Icons.add, color: AppColors.primary, size: 24),
            ),
          ),

          // 2. Central Content (Logo, Title, Subtitle)
          FadeTransition(
            opacity: _fadeAnimation,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo container with Pulse Glow in primary color
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Pulse Glow Effect (Primary Blue)
                      AnimatedBuilder(
                        animation: _glowAnimation,
                        builder: (context, child) {
                          final double glowOffset = _glowAnimation.value * 24.0;
                          return Container(
                            width: logoContainerSize + glowOffset,
                            height: logoContainerSize + glowOffset,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(
                                alpha: 0.08 * (1.0 - _glowAnimation.value),
                              ),
                              borderRadius: BorderRadius.circular(38),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.1 * (1.0 - _glowAnimation.value),
                                  ),
                                  blurRadius: 30,
                                  spreadRadius: 8.0 * _glowAnimation.value,
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      // Scale transitions for Logo Container
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          width: logoContainerSize,
                          height: logoContainerSize,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(logoContainerSize * 0.15),
                          child: Image.asset(
                            'assets/logo_cropped.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.work_outline_rounded,
                                  size: 60,
                                  color: AppColors.primary,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.04),

                  // Main Arabic Title (Dark Grey)
                  AnimatedOpacity(
                    opacity: _textOpacity1,
                    duration: const Duration(milliseconds: 600),
                    child: Text(
                      'مسارك',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.01),

                  // Subtitle description (Medium Grey)
                  AnimatedOpacity(
                    opacity: _textOpacity2,
                    duration: const Duration(milliseconds: 600),
                    child: Text(
                      'طريقك إلى الوظيفة المناسبة',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: subtitleFontSize,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Loading indicator at the bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: size.height * 0.08,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Loading label
                Text(
                  'جاري التحميل...',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),

                // Smooth linear progress bar (60% width)
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Container(
                    width: size.width * 0.6,
                    height: 4,
                    color: AppColors.primary.withValues(alpha: 0.1),
                    child: Stack(
                      children: [
                        AnimatedBuilder(
                          animation: _progressAnimation,
                          builder: (context, child) {
                            return Align(
                              alignment: Alignment.centerLeft,
                              child: FractionallySizedBox(
                                widthFactor: _progressAnimation.value,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
