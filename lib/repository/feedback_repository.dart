import 'package:gowork/model/feedback_model.dart';
import 'package:gowork/services/feedback_service.dart';

class FeedbackRepository {
  final FeedbackService _service = FeedbackService();

  Future<Map<String, dynamic>> submitFeedback(FeedbackRequest request) async {
    return await _service.submitFeedback(request);
  }
}
