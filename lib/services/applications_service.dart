import '../core/constants/api_constants.dart';
import '../utils/api_storage.dart';

class ApplicationsService {
  final ApiClient _apiClient;

  ApplicationsService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  Future<Map<String, dynamic>> getApplications() {
    return _apiClient.get(ApiConstants.applications);
  }

  Future<Map<String, dynamic>> getApplicationStatuses() {
    return _apiClient.get(ApiConstants.applicationStatuses);
  }

  Future<Map<String, dynamic>> withdrawApplication(String applicationId) {
    return _apiClient.post(
      '${ApiConstants.withdrawApplication}/$applicationId',
      {},
    );
  }
}
