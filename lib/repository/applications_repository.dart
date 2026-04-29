import 'package:gowork/model/application_model.dart';
import 'package:gowork/core/constants/api_constants.dart';
import 'package:gowork/utils/api_storage.dart';

class ApplicationsRepository {
  final ApiClient _apiClient = ApiClient();

  Future<List<ApplicationModel>> getApplications() async {
    try {
      final response = await _apiClient.get(ApiConstants.applications);
      if (response['data'] != null && response['data'] is List) {
        return (response['data'] as List)
            .map((json) => ApplicationModel.fromJson(json))
            .toList();
      } else if (response['applications'] != null) {
        return (response['applications'] as List)
            .map((json) => ApplicationModel.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getApplicationStatuses() async {
    try {
      final response = await _apiClient.get(ApiConstants.applicationStatuses);
      if (response['data'] != null && response['data'] is List) {
        return response['data'] as List<dynamic>;
      }
      return [];
    } catch (e) {
      // If endpoint doesn't exist or fails, return empty list to fallback
      return [];
    }
  }
}
