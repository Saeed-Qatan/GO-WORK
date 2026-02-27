import 'package:flutter/material.dart';

class SnackbarService {
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void showSuccess(String message) {
    _showSnackBar(
      message,
      Colors.green.shade600,
      Icons.check_circle_outline,
      const Duration(seconds: 3),
    );
  }

  static void showError(String message) {
    _showSnackBar(
      message,
      Colors.red.shade600,
      Icons.error_outline,
      const Duration(seconds: 4),
    );
  }

  static void showWarning(String message) {
    _showSnackBar(
      message,
      Colors.orange.shade700,
      Icons.warning_amber_rounded,
      const Duration(seconds: 4),
    );
  }

  static void showInfo(String message) {
    _showSnackBar(
      message,
      Colors.blue.shade600,
      Icons.info_outline,
      const Duration(seconds: 3),
    );
  }

  static void _showSnackBar(
    String message,
    Color color,
    IconData icon,
    Duration duration,
  ) {
    messengerKey.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ],
          ),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
          duration: duration,
        ),
      );
  }
}
