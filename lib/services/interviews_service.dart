import 'package:gowork/core/constants/api_constants.dart';
import 'package:gowork/utils/api_storage.dart';

class InterviewsService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> getInterviews() async {
    final response = await _apiClient.get(ApiConstants.candidateInterviews);
    return response;
  }

  Future<Map<String, dynamic>> submitInterviewAction(
    String id,
    String action, {
    String? notes,
  }) async {
    final response = await _apiClient.post(ApiConstants.interviewAction(id), {
      'action': action,
      if (notes != null) 'notes': notes,
    });
    return response;
  }
}
