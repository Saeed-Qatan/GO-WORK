import 'package:gowork/core/constants/api_constants.dart';
import 'package:gowork/utils/api_storage.dart';

class InterviewsService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> getInterviews() async {
    final response = await _apiClient.get(ApiConstants.candidateInterviews);
    return response;
  }

  Future<Map<String, dynamic>> submitInterviewAction(String id, String action, {String? notes}) async {
    // Assuming it's a POST request. The body might need adjustment based on backend definition.
    final response = await _apiClient.post(
      ApiConstants.interviewAction(id),
      {
        'status': action, // Assuming 'status' is the expected key (e.g., Confirmed, Declined)
        if (notes != null) 'notes': notes,
      },
    );
    return response;
  }
}
