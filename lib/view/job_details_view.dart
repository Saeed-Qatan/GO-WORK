import 'package:flutter/material.dart';
import '../model/home_model.dart';
import '../theme/app_colors.dart';
import 'dart:ui';

class JobDetailsView extends StatelessWidget {
  final JobModel job;

  const JobDetailsView({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    // Colors from the App Theme
    const Color surface = Color(0xFFF5F5F5); // Standard app background
    const Color surfaceContainerLow = AppColors.inputBackground;
    const Color onSurface = AppColors.textPrimary;
    const Color onSurfaceVariant = AppColors.textSecondary;
    final Color secondary = AppColors.primary.withValues(alpha: 0.8);
    const Color tertiaryContainer = Color(0xFF4CAF50); // Match Percentage Green
    const Color outlineVariant = AppColors.inputBorder;

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
                    Icons.arrow_forward, // Usually arrow forward implies back in RTL, but flutter handles auto-flipping if we use back, however let's follow the icon they chose in design for RTL
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
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.only(
              top: MediaQuery.paddingOf(context).top + kToolbarHeight + 24,
              left: 20,
              right: 20,
              bottom: 140 + MediaQuery.paddingOf(context).bottom, // safely clear bottom bar
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
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.business,
                            size: 40,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: tertiaryContainer.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  'ملاءمة بنسبة ${job.matchPercentage}%',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: tertiaryContainer,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2,
                                      ),
                                ),
                              ),
                              const SizedBox(height: 8),
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
                                      color: Colors.white.withValues(alpha: 0.8),
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
                                'نشر منذ 2 يوم',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.white.withValues(alpha: 0.8),
                                    ),
                              ),
                            ],
                          ),
                          // Applicants logic (mock)
                          Row(
                            children: [
                              Align(
                                widthFactor: 0.6,
                                child: _buildMockAvatar(Colors.blue.shade300),
                              ),
                              Align(
                                widthFactor: 0.6,
                                child: _buildMockAvatar(Colors.blue.shade400),
                              ),
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade500,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.primary,
                                    width: 2,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  '+12',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
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
                        'نوع الدوام', job.type, onSurfaceVariant, surfaceContainerLow),
                    const SizedBox(width: 12),
                    _buildInfoColumn(
                        'الموقع', job.location, onSurfaceVariant, surfaceContainerLow),
                    const SizedBox(width: 12),
                    _buildInfoColumn(
                        'النمط', job.workMode, onSurfaceVariant, surfaceContainerLow),
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
                      '${job.minSalary}k - ${job.maxSalary}k ر.س',
                      surfaceContainerLow,
                      onSurfaceVariant,
                      AppColors.primary,
                      isBoldHighlight: true,
                    ),
                    const SizedBox(height: 12),
                    _buildRowItem(
                      'تاريخ الانتهاء',
                      '15 أكتوبر 2024',
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
                  border: Border.all(color: outlineVariant.withValues(alpha: 0.1)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(32),
                child: Text(
                  'نحن نبحث عن مصمم واجهات مستخدم موهوب وشغوف للانضمام فريقنا المتنامي. ستكون مسؤولاً عن تحويل الرؤى المعقدة إلى واجهات مستخدم بديهية وجذابة بصرياً تعزز تجربة المستخدم الإجمالية.\n\nستعمل بشكل وثيق مع مديري المنتجات والمطورين لضمان تنفيذ التصاميم بأعلى معايير الجودة والاتساق مع هوية العلامة التجارية.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: onSurface,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    Text(
                      '6 مهارات',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildSkillBadge('Figma', Icons.category, Colors.blue),
                  _buildSkillBadge('UI Design', Icons.brush, Colors.purple),
                  _buildSkillBadge('Prototyping', Icons.bolt, Colors.orange),
                  _buildSkillBadge('Adobe Creative', Icons.palette, Colors.red),
                  _buildSkillBadge('User Research', Icons.search, Colors.green),
                  _buildSkillBadge('Design Systems', Icons.layers, Colors.indigo),
                ],
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
                      'التصميم والإبداع',
                      surfaceContainerLow,
                      onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    _buildAdditionalDetailRow(
                      Icons.star,
                      'المستوى الوظيفي',
                      'متوسط الخبرة',
                      surfaceContainerLow,
                      onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    _buildAdditionalDetailRow(
                      Icons.tag,
                      'رقم المرجع',
                      '#JD-99281',
                      surfaceContainerLow,
                      onSurfaceVariant,
                    ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                              elevation: 10,
                              shadowColor: AppColors.primary.withValues(alpha: 0.5),
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
                        const SizedBox(width: 16),
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: outlineVariant.withValues(alpha: 0.2),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.bookmark_outline),
                            color: onSurfaceVariant,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
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
                  child: Icon(
                    icon,
                    color: iconColor,
                  ),
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
      String label, String value, Color labelColor, Color bgColor) {
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
              style: TextStyle(
                color: labelColor,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
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
      String label, String value, Color bgColor, Color labelColor, Color valueColor,
      {bool isBoldHighlight = false}) {
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
          color: const Color(0xFFA7AAD7).withValues(alpha: 0.2), // outline-variant/20
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: iconColor,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalDetailRow(
      IconData icon, String label, String value, Color iconBgColor, Color labelColor) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            color: labelColor,
          ),
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
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMockAvatar(Color color) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary,
          width: 2,
        ),
      ),
    );
  }
}
