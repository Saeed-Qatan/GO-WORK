import 'package:flutter/material.dart';
import '../../model/interview_model.dart';

class InterviewsViewModel extends ChangeNotifier {
  List<InterviewModel> _interviews = [];
  List<InterviewModel> get interviews => _interviews;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  InterviewsViewModel() {
    fetchInterviews();
  }

  Future<void> fetchInterviews() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1000));

    _interviews = [
      InterviewModel(
        id: '1',
        role: 'React Frontend مطور',
        company: 'شركة التقنية المتقدمة',
        companyLogo: '',
        date: '2024-01-20',
        time: '10:00 ص',
        location: 'الرياض - مكتب الشركة',
        interviewerName: 'أحمد محمد',
        interviewerRole: 'مدير التطوير',
        status: InterviewStatus.confirmed,
      ),
      InterviewModel(
        id: '2',
        role: 'مصمم جرافيك',
        company: 'وكالة الإبداع الرقمي',
        companyLogo: '',
        date: '2024-01-22',
        time: '2:00 م',
        location: 'Zoom Meeting',
        interviewerName: 'سارة أحمد',
        interviewerRole: 'مديرة التصميم',
        status: InterviewStatus.waiting,
      ),
      InterviewModel(
        id: '3',
        role: 'مهندس برمجيات',
        company: 'شركة الحلول التقنية',
        companyLogo: '',
        date: '2024-01-25',
        time: '11:30 ص',
        location: 'الخبر - مكتب الشركة',
        interviewerName: 'محمد عامر',
        interviewerRole: 'كبير المهندسين',
        status: InterviewStatus.scheduled,
      ),
    ];

    _isLoading = false;
    notifyListeners();
  }
}
