class ApplicationsService {
  Future<Map<String, dynamic>> getApplications() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'applications': [
        {
          'id': '1',
          'role': 'مطور تطبيقات Flutter',
          'company': 'شركة التقنية العربية',
          'companyLogo': '',
          'date': '2023-10-25',
          'status': 'sent',
        },
        {
          'id': '2',
          'role': 'مصمم واجهات المستخدم UI/UX',
          'company': 'شركة الإبداع الرقمي',
          'companyLogo': '',
          'date': '2023-10-20',
          'status': 'inReview',
        },
        {
          'id': '3',
          'role': 'مهندس بيانات',
          'company': 'مجموعة المستقبل التقنية',
          'companyLogo': '',
          'date': '2023-10-15',
          'status': 'accepted',
        },
        {
          'id': '4',
          'role': 'مدير مشاريع تقنية',
          'company': 'شركة الحلول الذكية',
          'companyLogo': '',
          'date': '2023-10-10',
          'status': 'rejected',
        },
      ]
    };
  }
}
