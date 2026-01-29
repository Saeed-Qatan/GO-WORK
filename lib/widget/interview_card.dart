import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../model/interview_model.dart';

class InterviewCard extends StatelessWidget {
  final InterviewModel interview;

  const InterviewCard({super.key, required this.interview});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    Color statusBgColor;
    String statusText;
    IconData? statusIcon;

    switch (interview.status) {
      case InterviewStatus.confirmed:
        statusColor = const Color(0xFF2E7D32); // Green
        statusBgColor = const Color(0xFFE8F5E9);
        statusText = AppConstants.confirmed;
        statusIcon = Icons.check;
        break;
      case InterviewStatus.waiting:
        statusColor = const Color(0xFFB79C12); // Gold
        statusBgColor = const Color(0xFFFFF9C4);
        statusText = AppConstants.waitingConfirmation;
        statusIcon = Icons.access_time;
        break;
      case InterviewStatus.scheduled:
        statusColor = const Color(0xFF1565C0); // Blue
        statusBgColor = const Color(0xFFE3F2FD);
        statusText = AppConstants.scheduled;
        statusIcon = Icons.calendar_today;
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
          // Top Row: Status Badge & Role/Company
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(20), // Pill
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 14, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Role Info
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      interview.role,
                      textAlign: TextAlign.end,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      interview.company,
                      textAlign: TextAlign.end,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D47A1), // Place holder blue
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.business, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Info Rows: Date, Location, Interviewer
          _buildInfoRow(
            context,
            Icons.calendar_today_outlined,
            '${interview.date} في ${interview.time}',
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            context,
            Icons.location_on_outlined,
            interview.location,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            context,
            Icons.person_outline,
            '${interview.interviewerName} - ${interview.interviewerRole}',
          ),

          const SizedBox(height: 24),
          // Buttons
          Row(
            children: [
              // View Details Button (Blue Eye)
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.visibility_outlined,
                    color: Colors.white,
                  ),
                  onPressed: () {},
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Decline Button (Red)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.close, color: Colors.white, size: 18),
                  label: Text(
                    AppConstants.declineAttendance,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD32F2F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Confirm Button (Green)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.check, color: Colors.white, size: 18),
                  label: Text(
                    AppConstants.confirmAttendance,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF388E3C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          text,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
