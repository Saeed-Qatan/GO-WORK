class HomeService {
  Future<Map<String, dynamic>> getHomeData() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    return {
      'stats': [
        {'count': '3', 'label': 'مقابلات', 'type': 'interview'},
        {'count': '5', 'label': 'قيد المراجعة', 'type': 'review'},
        {'count': '12', 'label': 'طلبات مرسلة', 'type': 'sent'},
      ],
      'jobs': [
        {
          'id': '1',
          'title': 'مطور تطبيقات Flutter',
          'company': 'شركة التقنية العربية',
          'companyLogoUrl': '',
          'matchPercentage': 92,
          'category': 'تطوير البرمجيات',
          'location': 'الرياض',
          'type': 'دوام كامل',
          'workMode': 'عن بُعد',
          'minSalary': '12,000',
          'maxSalary': '18,000',
        },
        {
          'id': '2',
          'title': 'مصمم واجهات المستخدم UI/UX',
          'company': 'شركة الإبداع الرقمي',
          'companyLogoUrl': '',
          'matchPercentage': 85,
          'category': 'التصميم',
          'location': 'جدة',
          'type': 'دوام كامل',
          'workMode': 'هجين',
          'minSalary': '10,000',
          'maxSalary': '15,000',
        },
        {
          'id': '3',
          'title': 'مهندس بيانات',
          'company': 'مجموعة المستقبل التقنية',
          'companyLogoUrl': '',
          'matchPercentage': 78,
          'category': 'هندسة البيانات',
          'location': 'الدمام',
          'type': 'دوام جزئي',
          'workMode': 'حضوري',
          'minSalary': '14,000',
          'maxSalary': '22,000',
        },
        {
          'id': '4',
          'title': 'مدير مشاريع تقنية',
          'company': 'شركة الحلول الذكية',
          'companyLogoUrl': '',
          'matchPercentage': 88,
          'category': 'إدارة المشاريع',
          'location': 'الرياض',
          'type': 'دوام كامل',
          'workMode': 'هجين',
          'minSalary': '18,000',
          'maxSalary': '25,000',
        },
        {
          'id': '5',
          'title': 'محلل أمن سيبراني',
          'company': 'شركة الأمان الرقمي',
          'companyLogoUrl': '',
          'matchPercentage': 74,
          'category': 'الأمن السيبراني',
          'location': 'جدة',
          'type': 'دوام كامل',
          'workMode': 'عن بُعد',
          'minSalary': '16,000',
          'maxSalary': '24,000',
        },
      ],
    };
  }
}
