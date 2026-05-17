import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../model/home_model.dart';
import '../theme/app_colors.dart';
import '../viewmodel/job_details_view_model.dart';
import '../widget/common/pressable_button.dart';
import 'dart:ui';

class JobDetailsView extends StatefulWidget {
  final JobModel job;

  const JobDetailsView({super.key, required this.job});

  @override
  State<JobDetailsView> createState() => _JobDetailsViewState();
}

class _JobDetailsViewState extends State<JobDetailsView> {
  /// Local UI state for the bookmark/save toggle.
  bool _isSaved = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final viewModel = Provider.of<JobDetailsViewModel>(
          context,
          listen: false,
        );
        viewModel.setInitialJob(widget.job);
        viewModel.fetchJobDetails(widget.job.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Colors from the App Theme
    const Color surface = Color(0xFFF5F5F5); // Standard app background
    const Color surfaceContainerLow = AppColors.inputBackground;
    const Color onSurface = AppColors.textPrimary;
    const Color onSurfaceVariant = AppColors.textSecondary;
    final Color secondary = AppColors.primary.withValues(alpha: 0.8);
    const Color outlineVariant = AppColors.border;

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
                  color: outlineVariant, // border-outline-variant/10 basically
                  width: 0.2, // very thin
                ),
              ),
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons
                        .arrow_forward, // Usually arrow forward implies back in RTL, but flutter handles auto-flipping if we use back, however let's follow the icon they chose in design for RTL
                    color: AppColors.primary,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    shape: const CircleBorder(),
                  ),
                ),
              ),
              title: Text(
                'تفاصيل الوظيفة',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: onSurface,
                  fontWeight: FontWeight.w800, // extrabold
                ),
              ),
            ),
          ),
        ),
      ),
      body: Consumer<JobDetailsViewModel>(
        builder: (context, viewModel, child) {
          final job = viewModel.jobDetails ?? widget.job;
          final bool isLoading = viewModel.isLoading;

          String formattedExpDate = 'غير محدد';
          if (job.expirationDate != null) {
            formattedExpDate = job.expirationDate!.split('T').first;
          }

          String formattedPostedDate = _getTimeAgo(job.postedDate);

          final String currency = job.currency ?? 'ريال';

          return Stack(
            children: [
              ListView(
                padding: EdgeInsets.only(
                  top: MediaQuery.paddingOf(context).top + kToolbarHeight + 24,
                  left: 20,
                  right: 20,
                  bottom:
                      140 +
                      MediaQuery.paddingOf(
                        context,
                      ).bottom, // safely clear bottom bar
                ),
                children: [
                  // Hero Section
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [secondary, AppColors.primary],
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                      ),
                      borderRadius: BorderRadius.circular(48),
                    ),
                    padding: const EdgeInsets.all(32),
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
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                              child: job.companyLogoUrl.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        job.companyLogoUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(
                                              Icons.business,
                                              size: 32,
                                              color: AppColors.primary,
                                            ),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.business,
                                      size: 32,
                                      color: AppColors.primary,
                                    ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    job.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          height: 1.2,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    job.company,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Colors.white.withValues(
                                            alpha: 0.8,
                                          ),
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Container(
                          padding: const EdgeInsets.only(top: 16),
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                          ),
                          child: Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            runSpacing: 12,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.schedule,
                                    size: 16,
                                    color: Colors.white.withValues(alpha: 0.6),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    formattedPostedDate,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: Colors.white.withValues(
                                            alpha: 0.8,
                                          ),
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Work Environment Card
                  _buildGamifiedCard(
                    title: 'بيئة العمل',
                    icon: Icons.location_on,
                    iconColor: AppColors.primary,
                    iconBgColor: AppColors.primary.withValues(alpha: 0.1),
                    textColor: onSurface,
                    child: Row(
                      children: [
                        _buildInfoColumn(
                          'نوع الدوام',
                          job.type,
                          onSurfaceVariant,
                          surfaceContainerLow,
                        ),
                        const SizedBox(width: 12),
                        _buildInfoColumn(
                          'الدولة',
                          job.country.isNotEmpty ? job.country : 'غير محدد',
                          onSurfaceVariant,
                          surfaceContainerLow,
                        ),
                        const SizedBox(width: 12),
                        _buildInfoColumn(
                          'النمط',
                          job.workMode,
                          onSurfaceVariant,
                          surfaceContainerLow,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Features and Time Card
                  _buildGamifiedCard(
                    title: 'المميزات والوقت',
                    icon: Icons.payments,
                    iconColor: secondary,
                    iconBgColor: secondary.withValues(alpha: 0.1),
                    textColor: onSurface,
                    child: Column(
                      children: [
                        _buildRowItem(
                          'الراتب المتوقع',
                          '${job.minSalary} - ${job.maxSalary} $currency',
                          surfaceContainerLow,
                          onSurfaceVariant,
                          AppColors.primary,
                          isBoldHighlight: true,
                        ),
                        const SizedBox(height: 12),
                        _buildRowItem(
                          'تاريخ الانتهاء',
                          formattedExpDate,
                          surfaceContainerLow,
                          onSurfaceVariant,
                          onSurface,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Job Description
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'وصف الوظيفة',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(
                        color: outlineVariant.withValues(alpha: 0.1),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(32),
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Text(
                            job.description ?? 'لا يوجد وصف متاح',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: onSurfaceVariant,
                                  height: 2.0,
                                ),
                          ),
                  ),
                  const SizedBox(height: 32),

                  // Required Skills
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'المهارات المطلوبة',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: onSurface,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        Text(
                          isLoading
                              ? '...'
                              : '${job.skills?.length ?? 0} مهارة',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: job.skills != null && job.skills!.isNotEmpty
                              ? job.skills!
                                    .map(
                                      (skill) => _buildSkillBadge(
                                        skill,
                                        Icons.star_border,
                                        AppColors.primary,
                                      ),
                                    )
                                    .toList()
                              : [const Text('لا توجد مهارات محددة')],
                        ),
                  const SizedBox(height: 32),

                  // Additional Details
                  _buildGamifiedCard(
                    title: 'تفاصيل إضافية',
                    icon: null, // Title only
                    textColor: onSurface,
                    child: Column(
                      children: [
                        _buildAdditionalDetailRow(
                          Icons.work,
                          'القسم',
                          job.category,
                          surfaceContainerLow,
                          onSurfaceVariant,
                        ),

                        if (job.contactNumber != null &&
                            job.contactNumber!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _buildAdditionalDetailRow(
                            Icons.phone,
                            'رقم التواصل',
                            job.contactNumber!,
                            surfaceContainerLow,
                            onSurfaceVariant,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              // Bottom Fixed Action Bar
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 24,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        border: Border(
                          top: BorderSide(
                            color: outlineVariant.withValues(alpha: 0.1),
                          ),
                        ),
                      ),
                      child: SafeArea(
                        top: false,
                        child: Row(
                          children: [
                            Expanded(
                              // PressableButton (Listener-based) adds scale + haptic
                              // without blocking ElevatedButton's own gesture handling.
                              child: PressableButton(
                                hapticType: HapticFeedbackType.medium,
                                child: ElevatedButton(
                                  onPressed:
                                      (job.canApply == true && !isLoading)
                                      ? () => viewModel.applyToJob(
                                          context,
                                          job.id,
                                        )
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 20,
                                    ),
                                    backgroundColor: AppColors.primary,
                                    disabledBackgroundColor: AppColors.primary
                                        .withValues(alpha: 0.5),
                                    disabledForegroundColor: Colors.white
                                        .withValues(alpha: 0.8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(32),
                                    ),
                                    elevation: (job.canApply == true) ? 10 : 0,
                                    shadowColor: AppColors.primary.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'قدم الآن',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Icon(Icons.send, size: 20),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Animated bookmark button with bounce + haptic + toggle
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                setState(() => _isSaved = !_isSaved);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: _isSaved
                                      ? AppColors.primary.withValues(alpha: 0.1)
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: _isSaved
                                        ? AppColors.primary.withValues(
                                            alpha: 0.4,
                                          )
                                        : outlineVariant.withValues(alpha: 0.2),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(32),
                                ),
                                child: Center(
                                  child:
                                      Icon(
                                        _isSaved
                                            ? Icons.bookmark
                                            : Icons.bookmark_outline,
                                        key: ValueKey(_isSaved),
                                        color: _isSaved
                                            ? AppColors.primary
                                            : onSurfaceVariant,
                                      ).animate().scale(
                                        begin: const Offset(0.6, 0.6),
                                        end: const Offset(1.0, 1.0),
                                        duration: 350.ms,
                                        curve: Curves.elasticOut,
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGamifiedCard({
    required String title,
    IconData? icon,
    Color? iconColor,
    Color? iconBgColor,
    required Color textColor,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        border: const Border(
          bottom: BorderSide(
            color: Color(0x0C000000), // black/5
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (icon != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: iconColor),
                ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoColumn(
    String label,
    String value,
    Color labelColor,
    Color bgColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(color: labelColor, fontSize: 12),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRowItem(
    String label,
    String value,
    Color bgColor,
    Color labelColor,
    Color valueColor, {
    bool isBoldHighlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: labelColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: valueColor,
                fontWeight: isBoldHighlight ? FontWeight.w800 : FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillBadge(String text, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(
            0xFFA7AAD7,
          ).withValues(alpha: 0.2), // outline-variant/20
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalDetailRow(
    IconData icon,
    String label,
    String value,
    Color iconBgColor,
    Color labelColor,
  ) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: labelColor),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: labelColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  String _getTimeAgo(String? dateString) {
    if (dateString == null) return 'غير محدد';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 365) {
        return 'منذ ${difference.inDays ~/ 365} سنة';
      } else if (difference.inDays > 30) {
        return 'منذ ${difference.inDays ~/ 30} شهر';
      } else if (difference.inDays > 0) {
        return 'منذ ${difference.inDays} يوم';
      } else if (difference.inHours > 0) {
        return 'منذ ${difference.inHours} ساعة';
      } else if (difference.inMinutes > 0) {
        return 'منذ ${difference.inMinutes} دقيقة';
      } else {
        return 'قبل قليل';
      }
    } catch (e) {
      return 'نشر في ${dateString.split('T').first}';
    }
  }
}
