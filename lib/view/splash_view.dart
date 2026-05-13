import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gowork/utils/local_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:gowork/routing/app_router.dart';

import 'package:gowork/theme/app_colors.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    // Remove Native splash immediately so we can show our beautiful animated Dart Splash
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });
    _checkSession();
  }

  Future<void> _checkSession() async {
    // Adding a professional delay so the user experiences the smooth loading screen
    await Future.delayed(const Duration(milliseconds: 2500));

    final token = await LocalStorage().getString('token');

    if (mounted) {
      if (token != null) {
        context.go(AppRoutes.home);
      } else {
        context.go(AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
                  'assets/logo_cropped.png',
                  width: 160,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.work_outline_rounded,
                    size: 80,
                    color: AppColors.primary,
                  ),
                )
                .animate()
                .fade(duration: 800.ms)
                .scale(
                  begin: const Offset(0.8, 0.8),
                  duration: 800.ms,
                  curve: Curves.easeOutBack,
                )
                .shimmer(
                  delay: 800.ms,
                  duration: 1500.ms,
                  color: Colors.white54,
                ),
            const SizedBox(height: 50),
            const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  strokeWidth: 3,
                )
                .animate(delay: 500.ms)
                .fade(duration: 400.ms)
                .slideY(begin: 0.5, duration: 400.ms),
          ],
        ),
      ),
    );
  }
}
