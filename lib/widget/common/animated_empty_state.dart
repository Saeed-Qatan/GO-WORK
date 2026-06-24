import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_colors.dart';
import 'pressable_button.dart';

/// A premium animated empty state widget.
///
/// Uses procedural animations via [flutter_animate] to create a lively
/// and engaging experience when there is no data to show, replacing
/// standard boring static text.
class AnimatedEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionText;
  final VoidCallback? onAction;

  const AnimatedEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Floating animated icon container
            Stack(
              alignment: Alignment.center,
              children: [
                // Animated background glow
                Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: 0.05),
                      ),
                    )
                    .animate(onPlay: (controller) => controller.repeat())
                    .scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1.2, 1.2),
                      duration: 2000.ms,
                      curve: Curves.easeInOutSine,
                    )
                    .fade(
                      begin: 0.5,
                      end: 0.0,
                      duration: 2000.ms,
                      curve: Curves.easeOut,
                    ),

                // Main icon container
                Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(icon, size: 48, color: AppColors.primary),
                    )
                    .animate()
                    .scale(curve: Curves.easeOutBack, duration: 800.ms)
                    .then()
                    // Gentle floating animation
                    .slideY(
                      begin: 0,
                      end: 0.05,
                      duration: 1500.ms,
                      curve: Curves.easeInOutSine,
                    )
                    .then()
                    .slideY(
                      begin: 0.05,
                      end: 0,
                      duration: 1500.ms,
                      curve: Curves.easeInOutSine,
                    )
                    // Repeat the floating infinitely
                    .callback(
                      callback: (value) =>
                          value ? null : true, // Keeps repeating
                    ),
              ],
            ),
            const SizedBox(height: 32),

            // Staggered Title
            Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                )
                .animate()
                .fade(duration: 500.ms, delay: 200.ms)
                .slideY(
                  begin: 0.2,
                  end: 0,
                  duration: 500.ms,
                  curve: Curves.easeOut,
                ),

            const SizedBox(height: 12),

            // Staggered Subtitle
            Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                )
                .animate()
                .fade(duration: 500.ms, delay: 300.ms)
                .slideY(
                  begin: 0.2,
                  end: 0,
                  duration: 500.ms,
                  curve: Curves.easeOut,
                ),

            const SizedBox(height: 40),

            // Optional Action Button
            if (actionText != null && onAction != null)
              PressableButton(
                    hapticType: HapticFeedbackType.medium,
                    child: GestureDetector(
                      onTap: onAction,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          actionText!,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  )
                  .animate()
                  .fade(duration: 500.ms, delay: 500.ms)
                  .scale(curve: Curves.easeOutBack, delay: 500.ms),
          ],
        ),
      ),
    );
  }
}
