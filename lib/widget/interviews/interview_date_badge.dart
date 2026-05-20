import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Displays the interview date as a compact day/month badge.
class InterviewDateBadge extends StatelessWidget {
  /// The interview date. If null, placeholder dashes are shown.
  final DateTime? scheduledAt;

  /// Raw date string used as fallback month label when [scheduledAt] is null.
  final String rawDate;

  const InterviewDateBadge({
    super.key,
    required this.scheduledAt,
    required this.rawDate,
  });

  @override
  Widget build(BuildContext context) {
    final day = scheduledAt?.day.toString().padLeft(2, '0') ?? '--';
    final month = scheduledAt != null
        ? _monthName(scheduledAt!.month)
        : rawDate;

    return Container(
      width: 62,
      height: 70,
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            month,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  static String _monthName(int month) {
    const months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
    ];
    return months[month - 1];
  }
}
