import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../model/interview_model.dart';
import '../../routing/app_router.dart';
import '../../theme/app_colors.dart';
import '../../utils/snackbar_service.dart';
import '../../viewmodel/interviews_view_model.dart';
import 'interview_date_badge.dart';
import 'interview_status_chip.dart';
import 'interview_status_mapper.dart';

/// Orchestrates simplified interview card layout carrying only title, company, date, and actions.
class InterviewCard extends StatelessWidget {
  final InterviewModel interview;

  const InterviewCard({super.key, required this.interview});

  @override
  Widget build(BuildContext context) {
    final statusMeta = InterviewStatusMapper.forStatus(interview.status);
    final typeMeta = InterviewStatusMapper.forType(interview.interviewType);
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
                _buildActions(
                  context,
                  canRespond: canRespond,
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
              color: AppColors.textSecondary,
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

  Widget _buildActions(
    BuildContext context, {
    required bool canRespond,
    required bool isSubmitting,
    required bool isCancelSubmitting,
    required bool isConfirmSubmitting,
  }) {
    return Column(
      children: [
        const Divider(height: 1, color: AppColors.divider),
        Padding(
          padding: const EdgeInsets.all(12),
          child: canRespond
              ? Row(
                  children: [
                    Expanded(
                      child: _buildDeclineButton(
                        context,
                        isSubmitting,
                        isCancelSubmitting,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildConfirmButton(
                        context,
                        isSubmitting,
                        isConfirmSubmitting,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: _buildDetailsButton(context)),
                  ],
                )
              : Row(children: [Expanded(child: _buildDetailsButton(context))]),
        ),
      ],
    );
  }

  Widget _buildDeclineButton(
    BuildContext context,
    bool isSubmitting,
    bool isCancelSubmitting,
  ) {
    return _buildThemeButton(
      label: 'اعتذار',
      icon: Icons.close_rounded,
      backgroundColor: const Color(0xFFF5F5F5),
      foregroundColor: const Color(0xFF757575),
      isLoading: isCancelSubmitting,
      onPressed: isSubmitting ? null : () => _submitAction(context, 'cancel'),
    );
  }

  Widget _buildConfirmButton(
    BuildContext context,
    bool isSubmitting,
    bool isConfirmSubmitting,
  ) {
    return _buildThemeButton(
      label: 'تأكيد الحضور',
      icon: Icons.check_rounded,
      backgroundColor: const Color(0xFFE8EAF6),
      foregroundColor: const Color(0xFF3F51B5),
      isLoading: isConfirmSubmitting,
      onPressed: isSubmitting ? null : () => _submitAction(context, 'confirm'),
    );
  }

  Widget _buildDetailsButton(BuildContext context) {
    return _buildThemeButton(
      label: 'التفاصيل',
      icon: Icons.info_outline_rounded,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      isLoading: false,
      onPressed: () =>
          context.push(AppRoutes.interviewDetails, extra: interview),
    );
  }

  Widget _buildThemeButton({
    required String label,
    required IconData icon,
    required Color backgroundColor,
    required Color foregroundColor,
    required bool isLoading,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      height: 44,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          disabledBackgroundColor: backgroundColor.withValues(alpha: 0.5),
          foregroundColor: foregroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: foregroundColor,
                ),
              )
            else
              Icon(icon, color: foregroundColor, size: 16),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: foregroundColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitAction(BuildContext context, String action) async {
    final viewModel = context.read<InterviewsViewModel>();
    final success = await viewModel.submitAction(interview.id, action);
    if (!context.mounted) return;

    if (success) {
      SnackbarService.showSuccess(
        viewModel.successMessage ??
            (action == 'confirm'
                ? 'تم تأكيد المقابلة بنجاح'
                : 'تم إلغاء المقابلة بنجاح'),
      );
    } else {
      SnackbarService.showError(
        viewModel.errorMessage ??
            'تعذر تحديث حالة المقابلة، يرجى المحاولة مرة أخرى',
      );
    }
  }

  void _confirmDismiss(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'أرشفة المقابلة',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'هل أنت متأكد من رغبتك في أرشفة ونقل هذه المقابلة للمحذوفات؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<InterviewsViewModel>().dismissInterview(
                interview.id,
              );
              if (!context.mounted) return;
              SnackbarService.showSuccess('تم أرشفة ونقل المقابلة بنجاح');
            },
            child: const Text(
              'أرشفة',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
