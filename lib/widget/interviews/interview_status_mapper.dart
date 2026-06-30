import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../model/interview_model.dart';
import '../../theme/app_colors.dart';

/// Immutable value object carrying display metadata for an interview status.
class InterviewStatusMeta {
  final String label;
  final IconData icon;
  final Color color;
  final Color background;

  const InterviewStatusMeta({
    required this.label,
    required this.icon,
    required this.color,
    required this.background,
  });
}

/// Immutable value object carrying display metadata for an interview type.
class InterviewTypeMeta {
  final String label;
  final IconData icon;
  final Color color;
  final Color background;

  /// Whether this is a remote/online interview.
  final bool isOnline;

  const InterviewTypeMeta({
    required this.label,
    required this.icon,
    required this.color,
    required this.background,
    required this.isOnline,
  });
}

/// Pure stateless mapper: converts domain enums to UI display metadata.
///
/// Business Layer — zero dependency on Flutter widgets (only Color/IconData).
class InterviewStatusMapper {
  InterviewStatusMapper._();

  /// Maps [InterviewStatus] → [InterviewStatusMeta].
  static InterviewStatusMeta forStatus(InterviewStatus status) {
    switch (status) {
      case InterviewStatus.confirmed:
        return const InterviewStatusMeta(
          label: AppConstants.confirmed,
          icon: Icons.verified_rounded,
          color: AppColors.success,
          background: AppColors.successBackground,
        );
      case InterviewStatus.scheduled:
        return const InterviewStatusMeta(
          label: AppConstants.scheduled,
          icon: Icons.event_available_rounded,
          color: AppColors.info,
          background: AppColors.infoBackground,
        );
      case InterviewStatus.declined:
        return const InterviewStatusMeta(
          label: 'مرفوضة',
          icon: Icons.cancel_rounded,
          color: AppColors.error,
          background: AppColors.errorBackground,
        );
      case InterviewStatus.withdrawn:
        return const InterviewStatusMeta(
          label: 'منسحب',
          icon: Icons.logout_rounded,
          color: AppColors.warning,
          background: AppColors.warningBackground,
        );
      case InterviewStatus.missedInterview:
        return const InterviewStatusMeta(
          label: 'فائتة',
          icon: Icons.event_busy_rounded,
          color: AppColors.error,
          background: AppColors.errorBackground,
        );
      case InterviewStatus.waiting:
        return const InterviewStatusMeta(
          label: AppConstants.waitingConfirmation,
          icon: Icons.hourglass_top_rounded,
          color: AppColors.warning,
          background: AppColors.warningBackground,
        );
    }
  }

  /// Maps a raw type string (e.g. "Online", "InPerson") → [InterviewTypeMeta].
  static InterviewTypeMeta forType(String? rawType) {
    final value = rawType?.trim().toLowerCase();
    final isOnline = value == 'online' || value == 'remote';

    if (isOnline) {
      return const InterviewTypeMeta(
        label: 'عن بعد',
        icon: Icons.videocam_rounded,
        color: Color(0xFF5C6BC0),
        background: Color(0xFFEDE7F6),
        isOnline: true,
      );
    }

    return const InterviewTypeMeta(
      label: 'حضوري',
      icon: Icons.apartment_rounded,
      color: Color(0xFF6D4C41),
      background: Color(0xFFEFEBE9),
      isOnline: false,
    );
  }

  /// Returns a human-readable countdown string, or null if the date is past.
  static String? buildCountdown(DateTime? scheduledAt) {
    if (scheduledAt == null) return null;
    final now = DateTime.now();
    if (scheduledAt.isBefore(now)) return null;

    final diff = scheduledAt.difference(now);
    if (diff.inDays > 0) return 'بعد ${diff.inDays} يوم';
    if (diff.inHours > 0) return 'بعد ${diff.inHours} ساعة';
    if (diff.inMinutes > 0) return 'بعد ${diff.inMinutes} دقيقة';
    return null;
  }

  /// Builds a formatted time label from raw date/time strings.
  static String buildTimeLabel(String date, String time) {
    if (date.isEmpty && time.isEmpty) return 'لم يتم تحديد الموعد';
    if (date.isEmpty) return time;
    if (time.isEmpty) return date;
    return '$date  •  $time';
  }
}
