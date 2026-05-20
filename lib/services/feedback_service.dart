import 'package:gowork/core/constants/api_constants.dart';
import 'package:gowork/model/feedback_model.dart';
import 'package:gowork/utils/api_storage.dart';

class FeedbackService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> submitFeedback(FeedbackRequest request) async {
    return await _apiClient.post(ApiConstants.feedbacks, request.toJson());
  }
}
