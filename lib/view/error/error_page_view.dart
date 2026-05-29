import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gowork/theme/app_colors.dart';

/// Configuration data for [ErrorPageView].
/// Keeps parameters count under the maximum limit.
class ErrorPageData {
  final String title;
  final String message;
  final IconData icon;
  final Color themeColor;
  final String actionLabel;
  final VoidCallback onAction;

  const ErrorPageData({
    required this.title,
    required this.message,
    required this.icon,
    required this.themeColor,
    required this.actionLabel,
    required this.onAction,
  });
}

/// A premium, animated full-screen error page.
///
/// Uses [flutter_animate] to provide dynamic micro-animations.
class ErrorPageView extends StatelessWidget {
  final ErrorPageData data;

  const ErrorPageView({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            _buildBackgroundDecorations(),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildAnimatedIcon(),
                    const SizedBox(height: 32),
                    _buildTitleText(context),
                    const SizedBox(height: 16),
                    _buildMessageText(context),
                    const SizedBox(height: 40),
                    _buildActionButton(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundDecorations() {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: data.themeColor.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: data.themeColor.withValues(alpha: 0.03),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: data.themeColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: data.themeColor.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: Icon(
        data.icon,
        size: 56,
        color: data.themeColor,
      ),
    )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.05, 1.05),
          duration: 2.seconds,
          curve: Curves.easeInOut,
        )
        .then()
        .shake(duration: 800.ms, hz: 2);
  }

  Widget _buildTitleText(BuildContext context) {
    return Text(
      data.title,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
    )
        .animate()
        .fade(duration: 500.ms)
        .slideY(begin: 0.3, end: 0, duration: 500.ms);
  }

  Widget _buildMessageText(BuildContext context) {
    return Text(
      data.message,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            height: 1.6,
          ),
    )
        .animate()
        .fade(duration: 500.ms, delay: 150.ms)
        .slideY(begin: 0.3, end: 0, duration: 500.ms, delay: 150.ms);
  }

  Widget _buildActionButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: data.onAction,
        style: ElevatedButton.styleFrom(
          backgroundColor: data.themeColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          shadowColor: data.themeColor.withValues(alpha: 0.3),
        ),
        child: Text(
          data.actionLabel,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    )
        .animate()
        .fade(duration: 500.ms, delay: 300.ms)
        .scale(curve: Curves.easeOutBack, delay: 300.ms);
  }
}
