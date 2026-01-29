import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../model/application_model.dart';

class ApplicationCard extends StatelessWidget {
  final ApplicationModel application;

  const ApplicationCard({super.key, required this.application});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    Color statusBgColor;
    String statusText;
    IconData? statusIcon;

    switch (application.status) {
      case ApplicationStatus.inReview:
        statusColor = const Color(0xFFB79C12); // Goldish/Dark Yellow
        statusBgColor = const Color(0xFFFFF9C4); // Light Yellow
        statusText = AppConstants.statusReview;
        statusIcon = Icons.access_time;
        break;
      case ApplicationStatus.accepted:
        statusColor = const Color(0xFF2E7D32); // Green
        statusBgColor = const Color(0xFFE8F5E9); // Light Green
        statusText = AppConstants.statusAccepted;
        statusIcon = Icons.check;
        break;
      case ApplicationStatus.rejected:
        statusColor = const Color(0xFFC62828); // Red
        statusBgColor = const Color(0xFFFFEBEE); // Light Red
        statusText = AppConstants.statusRejected;
        statusIcon = Icons.close;
        break;
      case ApplicationStatus.sent:
        statusColor = const Color(0xFF1565C0); // Blue
        statusBgColor = const Color(0xFFE3F2FD); // Light Blue
        statusText = AppConstants.statusSent;
        statusIcon = null;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      statusText,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (statusIcon != null) ...[
                      const SizedBox(width: 4),
                      Icon(statusIcon, size: 14, color: statusColor),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application.role,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      application.company,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D47A1), // Dark Blue Placeholder
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.business, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.more_horiz,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.visibility_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '${AppConstants.datePrefix} ${application.date}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
