import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_constants.dart';
import '../../model/interview_model.dart';
import '../../theme/app_colors.dart';
import '../../viewmodel/interviews_view_model.dart';
import 'interview_action_button.dart';
import 'interview_countdown_banner.dart';
import 'interview_date_badge.dart';
import 'interview_detail_row.dart';
import 'interview_meeting_link_button.dart';
import 'interview_note_row.dart';
import 'interview_status_chip.dart';
import 'interview_status_mapper.dart';

/// Orchestrates all interview card sub-components into a single card layout.
///
/// Presentation Layer — zero business logic. All mapping is delegated to
/// [InterviewStatusMapper]; all sub-widgets are extracted as separate focused files.
class InterviewCard extends StatelessWidget {
  final InterviewModel interview;

  const InterviewCard({super.key, required this.interview});

  @override
  Widget build(BuildContext context) {
    final statusMeta = InterviewStatusMapper.forStatus(interview.status);
    final typeMeta = InterviewStatusMapper.forType(interview.interviewType);
    final countdown = InterviewStatusMapper.buildCountdown(
      interview.scheduledAt,
    );
    final timeLabel = InterviewStatusMapper.buildTimeLabel(
      interview.date,
      interview.time,
    );
    final canRespond =
        (interview.status == InterviewStatus.scheduled ||
            interview.status == InterviewStatus.waiting) &&
        !interview.isPast;

    return Consumer<InterviewsViewModel>(
      builder: (context, viewModel, _) {
        final isSubmitting = viewModel.isSubmitting(interview.id);
        final isCancelSubmitting = viewModel.isSubmittingAction(
          interview.id,
          'cancel',
        );
        final isConfirmSubmitting = viewModel.isSubmittingAction(
          interview.id,
          'confirm',
        );

        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context, statusMeta, typeMeta),
                if (countdown != null)
                  InterviewCountdownBanner(countdown: countdown),
                _buildDetails(typeMeta.isOnline, timeLabel),
                if (interview.meetingLink?.trim().isNotEmpty == true)
                  InterviewMeetingLinkButton(
                    link: interview.meetingLink!.trim(),
                    onTap: () => _openMeetingLink(context),
                  ),
                if (canRespond)
                  _buildActions(
                    context,
                    isSubmitting: isSubmitting,
                    isCancelSubmitting: isCancelSubmitting,
                    isConfirmSubmitting: isConfirmSubmitting,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Section builders ─────────────────────────────────────────────────────

  Widget _buildHeader(
    BuildContext context,
    InterviewStatusMeta statusMeta,
    InterviewTypeMeta typeMeta,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InterviewDateBadge(
            scheduledAt: interview.scheduledAt,
            rawDate: interview.date,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  interview.role.isNotEmpty ? interview.role : 'مقابلة عمل',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 5),
                _buildCompanyRow(context),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    InterviewStatusChip(
                      icon: statusMeta.icon,
                      label: statusMeta.label,
                      foreground: statusMeta.color,
                      background: statusMeta.background,
                    ),
                    InterviewStatusChip(
                      icon: typeMeta.icon,
                      label: typeMeta.label,
                      foreground: typeMeta.color,
                      background: typeMeta.background,
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              size: 24,
              color: AppColors.error,
            ),
            onPressed: () => _confirmDismiss(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyRow(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.business_rounded,
          size: 14,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            interview.company.isNotEmpty
                ? interview.company
                : 'الشركة غير محددة',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetails(bool isOnline, String timeLabel) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          InterviewDetailRow(
            icon: Icons.access_time_rounded,
            label: 'الموعد',
            text: timeLabel,
          ),
          if (interview.location.isNotEmpty) ...[
            const SizedBox(height: 10),
            InterviewDetailRow(
              icon: isOnline
                  ? Icons.videocam_outlined
                  : Icons.location_on_outlined,
              label: 'الموقع',
              text: interview.location,
            ),
          ],
          if (interview.notes?.trim().isNotEmpty == true) ...[
            const SizedBox(height: 10),
            InterviewNoteRow(note: interview.notes!.trim()),
          ],
        ],
      ),
    );
  }

  Widget _buildActions(
    BuildContext context, {
    required bool isSubmitting,
    required bool isCancelSubmitting,
    required bool isConfirmSubmitting,
  }) {
    return Column(
      children: [
        const Divider(height: 1, color: AppColors.divider),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: InterviewActionButton(
                  label: AppConstants.declineAttendance,
                  icon: Icons.close_rounded,
                  color: AppColors.error,
                  isLoading: isCancelSubmitting,
                  onPressed: isSubmitting
                      ? null
                      : () => _submitAction(context, 'cancel'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InterviewActionButton(
                  label: AppConstants.confirmAttendance,
                  icon: Icons.check_rounded,
                  color: AppColors.success,
                  isLoading: isConfirmSubmitting,
                  onPressed: isSubmitting
                      ? null
                      : () => _submitAction(context, 'confirm'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Actions ──────────────────────────────────────────────────────────────

  Future<void> _submitAction(BuildContext context, String action) async {
    final viewModel = context.read<InterviewsViewModel>();
    final success = await viewModel.submitAction(interview.id, action);
    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          success
              ? viewModel.successMessage ??
                    (action == 'confirm'
                        ? 'تم تأكيد المقابلة بنجاح'
                        : 'تم إلغاء المقابلة بنجاح')
              : viewModel.errorMessage ??
                    'تعذر تحديث حالة المقابلة، يرجى المحاولة مرة أخرى',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: success ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _openMeetingLink(BuildContext context) async {
    final rawLink = interview.meetingLink?.trim();
    if (rawLink == null || rawLink.isEmpty) return;

    final normalized = rawLink.startsWith('http')
        ? rawLink
        : 'https://$rawLink';
    final uri = Uri.tryParse(normalized);

    if (uri == null ||
        !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تعذر فتح رابط المقابلة'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _confirmDismiss(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'إخفاء المقابلة',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'هل أنت متأكد من رغبتك في إخفاء هذه المقابلة من القائمة؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<InterviewsViewModel>().dismissInterview(
                interview.id,
              );
            },
            child: const Text(
              'إخفاء',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
