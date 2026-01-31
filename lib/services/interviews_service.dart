import 'package:gowork/core/constants/api_constants.dart';
import 'package:gowork/utils/api_storage.dart';

class InterviewsService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> getInterviews() async {
    return await _apiClient.get(ApiConstants.interviews);
  }
}
