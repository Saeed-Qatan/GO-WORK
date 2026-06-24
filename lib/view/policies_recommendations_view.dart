import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PoliciesRecommendationsView extends StatelessWidget {
  const PoliciesRecommendationsView({super.key});

  static const List<_PolicySectionData> _sections = [
    _PolicySectionData(
      icon: Icons.verified_user_outlined,
      title: 'سياسات الاستخدام',
      body:
          'استخدم مسارك لتصفح الوظائف والتقديم عليها ببيانات صحيحة ومحدثة. يساعد اكتمال ملفك الشخصي على تحسين فرص ظهورك للفرص المناسبة.',
    ),
    _PolicySectionData(
      icon: Icons.lock_person_outlined,
      title: 'الخصوصية وحماية البيانات',
      body:
          'احرص على عدم مشاركة كلمة المرور أو بيانات الدخول مع أي جهة. يتم عرض معلوماتك المهنية بما يخدم تجربة التقديم والتواصل مع فرص العمل.',
    ),
    _PolicySectionData(
      icon: Icons.assignment_turned_in_outlined,
      title: 'التقديم على الوظائف',
      body:
          'راجع تفاصيل الوظيفة قبل التقديم وتأكد من توافق مهاراتك وخبراتك مع المتطلبات. تجنب إرسال طلبات متكررة لا تناسب ملفك المهني.',
    ),
    _PolicySectionData(
      icon: Icons.event_available_outlined,
      title: 'المقابلات والمتابعة',
      body:
          'تابع صفحة المقابلات والطلبات باستمرار، واستعد للمقابلة قبل موعدها بقراءة وصف الوظيفة وتجهيز أمثلة واضحة من خبراتك السابقة.',
    ),
    _PolicySectionData(
      icon: Icons.lightbulb_outline,
      title: 'توصيات مهنية',
      body:
          'حدّث مهاراتك وسيرتك الذاتية بانتظام، واكتب مسمى وظيفي واضح، وأضف المهارات الأكثر ارتباطا بالمجال الذي تبحث عنه.',
    ),
    _PolicySectionData(
      icon: Icons.shield_outlined,
      title: 'الاستخدام الآمن',
      body:
          'لا ترسل بيانات مالية أو وثائق حساسة خارج القنوات الرسمية. عند ملاحظة إعلان غير واضح أو طلب غير معتاد، استخدم الشكاوى والاقتراحات للتواصل معنا.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FB),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF5F7FB),
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          ),
          title: Text(
            'السياسات والتوصيات',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.18),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.policy_outlined,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'دليل مختصر لاستخدام مسارك بثقة',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'هذه الإرشادات تساعدك على تقديم طلبات أوضح، حماية بياناتك، ومتابعة فرصك المهنية بطريقة أفضل.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.88),
                      height: 1.7,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ..._sections.map(
              (section) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _PolicySection(section: section),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final _PolicySectionData section;

  const _PolicySection({required this.section});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(section.icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  section.body,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.65,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PolicySectionData {
  final IconData icon;
  final String title;
  final String body;

  const _PolicySectionData({
    required this.icon,
    required this.title,
    required this.body,
  });
}
