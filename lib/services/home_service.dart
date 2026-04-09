import 'package:flutter/foundation.dart';
import '../core/constants/api_constants.dart';
import '../utils/api_storage.dart';

class HomeService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> getHomeData() async {
    List<dynamic> jobsList = [];
    
    try {
      final response = await _apiClient.get(ApiConstants.recommendedJobs);
      
      // ApiClient returns Map<String, dynamic> and unwraps response
      if (response.containsKey('data')) {
        jobsList = response['data'] ?? [];
      } else if (response.containsKey('jobs')) {
        jobsList = response['jobs'] ?? [];
      } else if (response.isNotEmpty) {
        // If the map is just dictionary of jobs, wrap it (fallback)
        jobsList = [response];
      }
    } catch (e) {
      debugPrint('Failed to fetch recommended jobs: $e');
      // On failure, jobsList stays empty, but we let it return so stats still show.
    }

    return {
      'stats': [
        {'count': '3', 'label': 'مقابلات', 'type': 'interview'},
        {'count': '5', 'label': 'قيد المراجعة', 'type': 'review'},
        {'count': '12', 'label': 'طلبات مرسلة', 'type': 'sent'},
      ],
      'jobs': jobsList,
    };
  }


}
