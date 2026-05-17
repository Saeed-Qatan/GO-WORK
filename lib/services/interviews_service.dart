class InterviewsService {
  Future<Map<String, dynamic>> getInterviews() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'interviews': [
        {
          'id': '1',
          'role': 'مطور تطبيقات Flutter',
          'company': 'شركة التقنية العربية',
          'companyLogo': '',
          'date': '25 أكتوبر 2023',
          'time': '10:00 صباحاً',
          'location': 'عن بُعد (Zoom)',
          'interviewerName': 'أحمد محمد',
          'interviewerRole': 'مدير تقني',
          'status': 'confirmed',
        },
        {
          'id': '2',
          'role': 'مهندس بيانات',
          'company': 'مجموعة المستقبل التقنية',
          'companyLogo': '',
          'date': '30 أكتوبر 2023',
          'time': '02:00 مساءً',
          'location': 'الرياض، العليا',
          'interviewerName': 'سارة أحمد',
          'interviewerRole': 'مديرة الموارد البشرية',
          'status': 'waiting',
        },
      ],
    };
  }
}
