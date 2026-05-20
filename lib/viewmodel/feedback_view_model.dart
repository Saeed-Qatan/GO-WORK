import 'package:flutter/material.dart';
import 'package:gowork/model/feedback_model.dart';
import 'package:gowork/repository/feedback_repository.dart';
import 'package:gowork/utils/app_error_parser.dart';

class FeedbackViewModel extends ChangeNotifier {
  final FeedbackRepository _repository = FeedbackRepository();

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Future<bool> submitFeedback({
    required FeedbackType type,
    required String message,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final response = await _repository.submitFeedback(
        FeedbackRequest(type: type, message: message.trim()),
      );

      if (response['success'] == true) {
        _successMessage =
            response['data']?['message'] ?? 'تم إرسال الرسالة بنجاح';
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _errorMessage = AppErrorParser.parseResponseData(
        response,
        fallbackMessage: 'تعذر إرسال الرسالة، يرجى المحاولة مرة أخرى',
      );
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = AppErrorParser.parse(
        e,
        fallbackMessage: 'تعذر إرسال الرسالة، يرجى المحاولة مرة أخرى',
      );
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
