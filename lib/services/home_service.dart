import 'package:flutter/foundation.dart';
import '../core/constants/api_constants.dart';
import '../utils/api_storage.dart';

/// Service responsible for fetching all data needed by the Home screen.
class HomeService {
  final ApiClient _apiClient = ApiClient();

  /// Fetches recommended jobs, user info, and stats from the backend.
  /// Returns a map with keys: seekerFullName, seekerProfilePhoto, stats, jobs.
  Future<Map<String, dynamic>> getHomeData() async {
    List<dynamic> jobsList = [];
    List<Map<String, String>> statsList = [];
    String userName = '';
    String profilePhoto = '';
    int interviewsCount = 0;
    int pendingApps = 0;
    int totalApps = 0;
    bool statsFromRecommendations = false;

    // 1. Fetch recommended jobs (primary source for jobs + stats)
    try {
      debugPrint('=== HOME: Fetching ${ApiConstants.recommendedJobs} ===');
      final response = await _apiClient.get(ApiConstants.recommendedJobs);
      debugPrint(
        '=== HOME: recommendations keys: ${response.keys.toList()} ===',
      );

      if (response.containsKey('data')) {
        final data = response['data'];
        debugPrint('=== HOME: data type: ${data.runtimeType} ===');

        if (data is Map<String, dynamic>) {
          debugPrint('=== HOME: data keys: ${data.keys.toList()} ===');

          // Extract user info
          userName = data['seekerFullName']?.toString() ?? '';
          profilePhoto =
              data['seekerProfilePhoto']?.toString() ??
              data['profilPhotoUrl']?.toString() ??
              '';

          // Extract recommended jobs
          if (data.containsKey('recommendations') &&
              data['recommendations'] is List) {
            jobsList = data['recommendations'];
            debugPrint('=== HOME: Found ${jobsList.length} jobs ===');
          }

          // Extract stats from recommendations response (original approach)
          if (data.containsKey('totalInterviewsCount') ||
              data.containsKey('totalApplicationsCount') ||
              data.containsKey('pendingReviewApplicationsCount')) {
            interviewsCount = _toInt(data['totalInterviewsCount']);
            pendingApps = _toInt(data['pendingReviewApplicationsCount']);
            totalApps = _toInt(data['totalApplicationsCount']);
            statsFromRecommendations = true;
            debugPrint(
              '=== HOME: Stats from recommendations: interviews=$interviewsCount, pending=$pendingApps, total=$totalApps ===',
            );
          }
        } else if (data is List) {
          jobsList = data;
          debugPrint('=== HOME: data is List with ${data.length} items ===');
        }
      } else if (response.containsKey('recommendations') &&
          response['recommendations'] is List) {
        jobsList = response['recommendations'];
      } else if (response.containsKey('jobs') && response['jobs'] is List) {
        jobsList = response['jobs'];
      }
    } catch (e) {
      debugPrint('=== HOME ERROR: recommendations: $e ===');
    }

    // 1b. Fallback: if no recommendations, fetch from Jobs/search
    if (jobsList.isEmpty) {
      try {
        debugPrint(
          '=== HOME: No recommendations, trying ${ApiConstants.searchJobs} ===',
        );
        final searchResp = await _apiClient.get(ApiConstants.searchJobs);
        debugPrint('=== HOME: search keys: ${searchResp.keys.toList()} ===');

        if (searchResp['data'] is List) {
          jobsList = searchResp['data'];
        } else if (searchResp['data'] is Map<String, dynamic>) {
          final searchData = searchResp['data'] as Map<String, dynamic>;
          if (searchData['items'] is List) {
            jobsList = searchData['items'];
          } else if (searchData['jobs'] is List) {
            jobsList = searchData['jobs'];
          }
        } else if (searchResp['jobs'] is List) {
          jobsList = searchResp['jobs'];
        } else if (searchResp['items'] is List) {
          jobsList = searchResp['items'];
        }
        debugPrint(
          '=== HOME: Search fallback found ${jobsList.length} jobs ===',
        );
      } catch (e) {
        debugPrint('=== HOME ERROR: search fallback: $e ===');
      }
    }

    // 2. If stats were NOT in the recommendations response, try individual endpoints
    if (!statsFromRecommendations) {
      debugPrint(
        '=== HOME: Stats not in recommendations, fetching individually ===',
      );

      // Fetch interviews count
      try {
        final resp = await _apiClient.get(ApiConstants.interviews);
        debugPrint('=== HOME: interviews keys: ${resp.keys.toList()} ===');
        if (resp['data'] is List) {
          interviewsCount = (resp['data'] as List).length;
        } else if (resp['interviews'] is List) {
          interviewsCount = (resp['interviews'] as List).length;
        } else if (resp.containsKey('totalCount')) {
          interviewsCount = _toInt(resp['totalCount']);
        }
        debugPrint('=== HOME: interviewsCount=$interviewsCount ===');
      } catch (e) {
        debugPrint('=== HOME ERROR: interviews: $e ===');
      }

      // Fetch applications count
      try {
        final resp = await _apiClient.get(ApiConstants.applications);
        debugPrint('=== HOME: applications keys: ${resp.keys.toList()} ===');
        List<dynamic> apps = [];
        if (resp['data'] is List) {
          apps = resp['data'];
        } else if (resp['applications'] is List) {
          apps = resp['applications'];
        }
        totalApps = apps.length;
        for (var app in apps) {
          final s = app['status']?.toString().toLowerCase() ?? '';
          final statusId = app['statusId']?.toString().toLowerCase() ?? '';
          final statusValue =
              app['statusValue']?.toString().toLowerCase() ?? '';
          if (_isPendingReviewStatus(s) ||
              _isPendingReviewStatus(statusId) ||
              _isPendingReviewStatus(statusValue)) {
            pendingApps++;
          }
        }
        if (totalApps == 0 && resp.containsKey('totalCount')) {
          totalApps = _toInt(resp['totalCount']);
        }
        debugPrint(
          '=== HOME: totalApps=$totalApps, pendingApps=$pendingApps ===',
        );
      } catch (e) {
        debugPrint('=== HOME ERROR: applications: $e ===');
      }
    }

    // Build stats list
    statsList = [
      {
        'count': interviewsCount.toString(),
        'label': 'مقابلات',
        'type': 'interview',
      },
      {
        'count': pendingApps.toString(),
        'label': 'قيد المراجعة',
        'type': 'review',
      },
      {'count': totalApps.toString(), 'label': 'طلبات مرسلة', 'type': 'sent'},
    ];

    debugPrint(
      '=== HOME FINAL: user=$userName, jobs=${jobsList.length}, stats=$statsList ===',
    );

    return {
      'seekerFullName': userName,
      'seekerProfilePhoto': profilePhoto,
      'stats': statsList,
      'jobs': jobsList,
    };
  }

  /// Safely converts a dynamic value to int.
  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  bool _isPendingReviewStatus(String value) {
    final normalized = value.trim().toLowerCase().replaceAll(
      RegExp(r'[\s_\-]+'),
      '',
    );

    if (normalized.isEmpty) return false;
    return normalized == '1' ||
        normalized == 'pendingreview' ||
        normalized.contains('pending') ||
        normalized.contains('review');
  }
}
