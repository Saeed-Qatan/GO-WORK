import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:gowork/utils/local_storage.dart';
import 'package:gowork/utils/navigations.dart';
import 'package:gowork/view/auth/login_view.dart';

import 'package:gowork/view/main_view.dart';
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
      if (token != null && token.isNotEmpty) {
        NavigationService.pushReplacement(const LoginView());
      } else {
        NavigationService.pushReplacement(const MainView());
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
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return UI_SplashLogo(value: value);
              },
            ),
            const SizedBox(height: 50),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeIn,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                    strokeWidth: 3,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class UI_SplashLogo extends StatelessWidget {
  final double value;
  const UI_SplashLogo({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 0.8 + (value * 0.2), // Scales from 0.8 to 1.0
      child: Opacity(
        opacity: value,
        child: Image.asset(
          'assets/logo_cropped.png',
          width: 160,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.work_outline_rounded,
            size: 80,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
