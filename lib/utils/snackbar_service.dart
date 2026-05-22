import 'package:flutter/material.dart';
import 'package:gowork/theme/app_colors.dart';
import 'status_translator.dart';

class SnackbarService {
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void showSuccess(String message) {
    _showPremiumSnackBar(
      message,
      AppColors.success,
      Icons.check_circle_rounded,
      const Duration(seconds: 3),
    );
  }

  static void showError(String message) {
    _showPremiumSnackBar(
      message,
      AppColors.error,
      Icons.error_rounded,
      const Duration(seconds: 4),
    );
  }

  static void showWarning(String message) {
    _showPremiumSnackBar(
      message,
      AppColors.warning,
      Icons.warning_rounded,
      const Duration(seconds: 4),
    );
  }

  static void showInfo(String message) {
    _showPremiumSnackBar(
      message,
      AppColors.info,
      Icons.info_rounded,
      const Duration(seconds: 3),
    );
  }

  static void _showPremiumSnackBar(
    String message,
    Color backgroundColor,
    IconData icon,
    Duration duration,
  ) {
    final displayMessage = StatusTranslator.backendMessage(message);
    messengerKey.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
          duration: duration,
          content: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: backgroundColor.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    displayMessage,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }
}
