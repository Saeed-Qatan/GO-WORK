import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_colors.dart';
import 'pressable_button.dart';

/// A premium, highly-animated bottom sheet to celebrate a successful action.
///
/// Use [showSuccessBottomSheet] to display this globally.
class SuccessBottomSheet extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback onButtonPressed;

  const SuccessBottomSheet({
    super.key,
    required this.title,
    required this.message,
    this.buttonText = 'حسناً',
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Trigger haptic feedback on success
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 150), () {
      HapticFeedback.mediumImpact();
    });

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 32),
          
          // Animated Checkmark Icon
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9), // Light green
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Color(0xFF4CAF50), // Green
              size: 50,
            ),
          )
              .animate()
              .scale(curve: Curves.elasticOut, duration: 1000.ms)
              .shimmer(delay: 400.ms, duration: 1000.ms, color: Colors.white),

          const SizedBox(height: 24),

          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          )
              .animate()
              .fade(delay: 200.ms, duration: 400.ms)
              .slideY(begin: 0.5, end: 0, delay: 200.ms, duration: 400.ms, curve: Curves.easeOut),

          const SizedBox(height: 12),

          // Message
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          )
              .animate()
              .fade(delay: 300.ms, duration: 400.ms)
              .slideY(begin: 0.5, end: 0, delay: 300.ms, duration: 400.ms, curve: Curves.easeOut),

          const SizedBox(height: 40),

          // Action Button
          SizedBox(
            width: double.infinity,
            child: PressableButton(
              hapticType: HapticFeedbackType.medium,
              child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  onButtonPressed();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50), // Green
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          )
              .animate()
              .fade(delay: 400.ms, duration: 400.ms)
              .slideY(begin: 0.5, end: 0, delay: 400.ms, duration: 400.ms, curve: Curves.easeOut),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// Helper function to easily show the success bottom sheet.
void showSuccessBottomSheet({
  required BuildContext context,
  required String title,
  required String message,
  String buttonText = 'حسناً',
  VoidCallback? onButtonPressed,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => SuccessBottomSheet(
      title: title,
      message: message,
      buttonText: buttonText,
      onButtonPressed: () {
        Navigator.of(context).pop();
        if (onButtonPressed != null) {
          onButtonPressed();
        }
      },
    ),
  );
}
