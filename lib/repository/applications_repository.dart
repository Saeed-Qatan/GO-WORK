import 'package:flutter/foundation.dart';
import 'package:gowork/model/application_model.dart';
import 'package:gowork/core/constants/api_constants.dart';
import 'package:gowork/utils/api_storage.dart';

class ApplicationsRepository {
  final ApiClient _apiClient;

  ApplicationsRepository({ApiClient? apiClient}) 
      : _apiClient = apiClient ?? ApiClient();

  Future<List<ApplicationModel>> getApplications() async {
    try {
      debugPrint('=== APPLICATIONS: Fetching ${ApiConstants.applications} ===');
      final response = await _apiClient.get(ApiConstants.applications);
      debugPrint('=== APPLICATIONS: response keys: ${response.keys.toList()} ===');
      
      if (response.containsKey('data')) {
        debugPrint('=== APPLICATIONS: data type: ${response['data'].runtimeType} ===');
        if (response['data'] is Map) {
          debugPrint('=== APPLICATIONS: data keys: ${(response['data'] as Map).keys.toList()} ===');
        }
      }

      List<dynamic> rawList = [];

      if (response['data'] != null && response['data'] is List) {
        rawList = response['data'] as List;
      } else if (response['data'] != null && response['data'] is Map) {
        final dataMap = response['data'] as Map<String, dynamic>;
        if (dataMap.containsKey('items') && dataMap['items'] is List) {
          rawList = dataMap['items'] as List;
        } else if (dataMap.containsKey('applications') && dataMap['applications'] is List) {
          rawList = dataMap['applications'] as List;
        }
      } else if (response['applications'] != null && response['applications'] is List) {
        rawList = response['applications'] as List;
      } else if (response['items'] != null && response['items'] is List) {
        rawList = response['items'] as List;
      }

      debugPrint('=== APPLICATIONS: Found ${rawList.length} raw items ===');
      
      return rawList.map((json) {
        try {
          return ApplicationModel.fromJson(json as Map<String, dynamic>);
        } catch (e) {
          debugPrint('=== APPLICATIONS: Error parsing item: $e ===');
          return ApplicationModel(
            id: '', 
            jobId: '',
            role: 'Error', 
            company: 'Error', 
            companyLogo: '', 
            date: '', 
            statusName: 'Error', 
            status: ApplicationStatus.sent,
          );
        }
      }).where((app) => app.id.isNotEmpty).toList();
    } catch (e) {
      debugPrint('=== APPLICATIONS ERROR: $e ===');
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

  Future<void> withdrawApplication(String applicationId) async {
    try {
      await _apiClient.post('${ApiConstants.withdrawApplication}/$applicationId', {});
    } catch (e) {
      rethrow;
    }
  }
}
