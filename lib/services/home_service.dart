import 'package:flutter/foundation.dart';
import '../core/constants/api_constants.dart';
import '../utils/api_storage.dart';

class HomeService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> getHomeData() async {
    List<dynamic> jobsList = [];
    List<Map<String, String>> statsList = [];
    String userName = '';
    
    try {
      final response = await _apiClient.get(ApiConstants.recommendedJobs);
      
      if (response.containsKey('data')) {
        final dataStr = response['data'];
        
        if (dataStr is Map<String, dynamic>) {
          userName = dataStr['seekerFullName'] ?? '';
          
          // Parse jobs
          if (dataStr.containsKey('recommendations')) {
            jobsList = dataStr['recommendations'] ?? [];
          }
          
          // Parse stats
          statsList = [
            {
              'count': (dataStr['totalInterviewsCount'] ?? 0).toString(),
              'label': 'مقابلات',
              'type': 'interview'
            },
            {
              'count': (dataStr['pendingReviewApplicationsCount'] ?? 0).toString(),
              'label': 'قيد المراجعة',
              'type': 'review'
            },
            {
              'count': (dataStr['totalApplicationsCount'] ?? 0).toString(),
              'label': 'طلبات مرسلة',
              'type': 'sent'
            },
          ];
        } else if (dataStr is List) {
           // Backend returns array of jobs directly in data
           jobsList = dataStr;
        }



      } else if (response.containsKey('jobs')) {
        // Fallback for older format if it ever happens
        jobsList = response['jobs'] ?? [];
      } else if (response.isNotEmpty) {
        jobsList = [response];
      }
    } catch (e) {
      debugPrint('Failed to fetch recommended jobs: $e');
    }

    // Default stats if none were parsed
    if (statsList.isEmpty) {
      statsList = [
        {'count': '0', 'label': 'مقابلات', 'type': 'interview'},
        {'count': '0', 'label': 'قيد المراجعة', 'type': 'review'},
        {'count': '0', 'label': 'طلبات مرسلة', 'type': 'sent'},
      ];
    }

    return {
      'seekerFullName': userName,
      'stats': statsList,
      'jobs': jobsList,
    };
  }


}
