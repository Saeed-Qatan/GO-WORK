import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/interview_model.dart';
import '../theme/app_colors.dart';
import '../widget/interviews/interview_status_mapper.dart';
import '../widget/interviews/interview_status_chip.dart';
import '../utils/snackbar_service.dart';

class InterviewDetailsView extends StatelessWidget {
  final InterviewModel interview;

  const InterviewDetailsView({super.key, required this.interview});

  @override
  Widget build(BuildContext context) {
    const Color surface = Color(0xFFF5F5F5); // Standard app background
    const Color onSurface = AppColors.textPrimary;
    final Color secondary = AppColors.primary.withValues(alpha: 0.8);
    const Color outlineVariant = AppColors.border;

    final statusMeta = InterviewStatusMapper.forStatus(interview.status);
    final typeMeta = InterviewStatusMapper.forType(interview.interviewType);
    final timeLabel = InterviewStatusMapper.buildTimeLabel(
      interview.date,
      interview.time,
    );

    return Scaffold(
      backgroundColor: surface,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              backgroundColor: Colors.white.withValues(alpha: 0.7),
              elevation: 0,
              centerTitle: true,
              shape: const Border(
                bottom: BorderSide(
                  color: outlineVariant,
                  width: 0.2,
                ),
              ),
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_forward, // Egyptian RTL back arrow standard
                    color: AppColors.primary,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    shape: const CircleBorder(),
                  ),
                ),
              ),
              title: Text(
                'تفاصيل المقابلة',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          top: MediaQuery.paddingOf(context).top + kToolbarHeight + 24,
          left: 20,
          right: 20,
          bottom: 40 + MediaQuery.paddingOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [secondary, AppColors.primary],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: interview.companyLogo != null &&
                                interview.companyLogo!.isNotEmpty
                            ? Image.network(
                                interview.companyLogo!,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.business_rounded,
                                  color: AppColors.primary,
                                  size: 28,
                                ),
                              )
                            : const Icon(
                                Icons.business_rounded,
                                color: AppColors.primary,
                                size: 28,
                              ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              interview.role.isNotEmpty
                                  ? interview.role
                                  : 'مقابلة عمل',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              interview.company.isNotEmpty
                                  ? interview.company
                                  : 'الشركة غير محددة',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      InterviewStatusChip(
                        icon: statusMeta.icon,
                        label: statusMeta.label,
                        foreground: statusMeta.color,
                        background: Colors.white,
                      ),
                      const SizedBox(width: 10),
                      InterviewStatusChip(
                        icon: typeMeta.icon,
                        label: typeMeta.label,
                        foreground: typeMeta.color,
                        background: Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fade(duration: 400.ms).slideY(
                  begin: 0.2,
                  curve: Curves.easeOutCubic,
                  duration: 400.ms,
                ),
            const SizedBox(height: 24),

            // Detail Sections
            _buildSectionCard(
              title: 'معلومات المقابلة',
              icon: Icons.event_note_rounded,
              children: [
                _buildInfoRow(
                  icon: Icons.access_time_rounded,
                  label: 'الوقت والتاريخ',
                  value: timeLabel,
                ),
                _buildInfoRow(
                  icon: typeMeta.isOnline
                      ? Icons.videocam_outlined
                      : Icons.location_on_outlined,
                  label: 'الموقع',
                  value: interview.location.isNotEmpty
                      ? interview.location
                      : 'غير محدد',
                ),
              ],
            ).animate().fade(duration: 400.ms, delay: 100.ms).slideY(
                  begin: 0.2,
                  curve: Curves.easeOutCubic,
                  duration: 400.ms,
                  delay: 100.ms,
                ),
            const SizedBox(height: 16),

            // Interviewer Info Section
            if (interview.interviewerName?.isNotEmpty == true ||
                interview.interviewerRole?.isNotEmpty == true)
              _buildSectionCard(
                title: 'معلومات المقابل',
                icon: Icons.person_outline_rounded,
                children: [
                  if (interview.interviewerName?.isNotEmpty == true)
                    _buildInfoRow(
                      icon: Icons.badge_outlined,
                      label: 'الاسم',
                      value: interview.interviewerName!,
                    ),
                  if (interview.interviewerRole?.isNotEmpty == true)
                    _buildInfoRow(
                      icon: Icons.work_outline_rounded,
                      label: 'المنصب الوظيفي',
                      value: interview.interviewerRole!,
                    ),
                ],
              ).animate().fade(duration: 400.ms, delay: 150.ms).slideY(
                    begin: 0.2,
                    curve: Curves.easeOutCubic,
                    duration: 400.ms,
                    delay: 150.ms,
                  ),
            if (interview.interviewerName?.isNotEmpty == true ||
                interview.interviewerRole?.isNotEmpty == true)
              const SizedBox(height: 16),

            // Notes Section
            if (interview.notes?.trim().isNotEmpty == true)
              _buildSectionCard(
                title: 'ملاحظات تفصيلية',
                icon: Icons.description_outlined,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      interview.notes!.trim(),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 15,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ).animate().fade(duration: 400.ms, delay: 200.ms).slideY(
                    begin: 0.2,
                    curve: Curves.easeOutCubic,
                    duration: 400.ms,
                    delay: 200.ms,
                  ),
            if (interview.notes?.trim().isNotEmpty == true)
              const SizedBox(height: 24),

            // Interactive Meeting Link Button if Remote
            if (interview.meetingLink?.trim().isNotEmpty == true)
              _buildMeetingButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingButton(BuildContext context) {
    final bool isBlocked = interview.status == InterviewStatus.declined;

    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: isBlocked
            ? const LinearGradient(
                colors: [Color(0xFFE0E0E0), Color(0xFFBDBDBD)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : const LinearGradient(
                colors: [Color(0xFF5C6BC0), Color(0xFF3F51B5)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isBlocked
                ? Colors.black.withValues(alpha: 0.05)
                : const Color(0xFF3F51B5).withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openMeetingLink(context),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.videocam_rounded,
                color: isBlocked ? Colors.grey[600] : Colors.white,
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                isBlocked
                    ? 'رابط المقابلة محجوب (تم الاعتذار/الإلغاء)'
                    : 'الانضمام للمقابلة (رابط الاجتماع)',
                style: TextStyle(
                  color: isBlocked ? Colors.grey[700] : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fade(duration: 400.ms, delay: 250.ms).slideY(
          begin: 0.2,
          curve: Curves.easeOutCubic,
          duration: 400.ms,
          delay: 250.ms,
        );
  }

  Future<void> _openMeetingLink(BuildContext context) async {
    if (interview.status == InterviewStatus.declined) {
      SnackbarService.showWarning(
        'لا يمكنك الانضمام لمقابلة قمت بالاعتذار عنها أو تم إلغاؤها',
      );
      return;
    }

    final rawLink = interview.meetingLink?.trim();
    if (rawLink == null || rawLink.isEmpty) return;

    final normalized = rawLink.startsWith('http')
        ? rawLink
        : 'https://$rawLink';
    final uri = Uri.tryParse(normalized);

    if (uri == null ||
        !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      SnackbarService.showError('تعذر فتح رابط المقابلة');
    }
  }
}
