import 'package:flutter/material.dart';
import '../model/interview_model.dart';
import '../repository/interviews_repository.dart';

class InterviewsViewModel extends ChangeNotifier {
  final InterviewsRepository _repository = InterviewsRepository();
  List<InterviewModel> _interviews = [];
  List<InterviewModel> get interviews => _interviews;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  InterviewsViewModel() {
    fetchInterviews();
  }

  Future<void> fetchInterviews() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _interviews = await _repository.getInterviews();
    } catch (e) {
      _errorMessage = 'حدث خطأ أثناء جلب المقابلات: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitAction(String interviewId, String action, {String? notes}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _repository.submitInterviewAction(interviewId, action, notes: notes);
      if (success) {
        await fetchInterviews();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'حدث خطأ أثناء تحديث حالة المقابلة: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
