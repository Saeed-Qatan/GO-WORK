import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Displays a soft countdown chip showing time remaining until the interview.
///
/// Only rendered when the interview is upcoming (future date).
class InterviewCountdownBanner extends StatelessWidget {
  /// Human-readable countdown string, e.g. "بعد 3 أيام".
  final String countdown;

  const InterviewCountdownBanner({super.key, required this.countdown});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.timer_rounded,
            color: AppColors.textSecondary,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            countdown,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
