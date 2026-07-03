import 'package:flutter/foundation.dart';
import 'package:gowork/model/interview_model.dart';

import '../core/constants/api_constants.dart';
import '../utils/api_storage.dart';

/// Service responsible for fetching all data needed by the Home screen.
class HomeService {
  final ApiClient _apiClient;

  HomeService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Fetches recommended jobs, user info, and home stats.
  ///
  /// Interview count is always calculated from CandidateInterviews and only
  /// counts InterviewStatus.confirmed. Recommendation stats are not trusted for
  /// this number because they can be stale or count different statuses.
  Future<Map<String, dynamic>> getHomeData() async {
    List<dynamic> jobsList = [];
    String userName = '';
    String profilePhoto = '';
    int pendingApps = 0;
    int totalApps = 0;

    try {
      debugPrint('=== HOME: Fetching ${ApiConstants.recommendedJobs} ===');
      final response = await _apiClient.get(ApiConstants.recommendedJobs);
      final data = response['data'];

      if (data is Map<String, dynamic>) {
        userName = data['seekerFullName']?.toString() ?? '';
        profilePhoto =
            data['seekerProfilePhoto']?.toString() ??
            data['profilPhotoUrl']?.toString() ??
            '';

        if (data['recommendations'] is List) {
          jobsList = data['recommendations'] as List<dynamic>;
        }

        pendingApps = _toInt(data['pendingReviewApplicationsCount']);
        totalApps = _toInt(data['totalApplicationsCount']);
      } else if (data is List) {
        jobsList = data;
      } else if (response['recommendations'] is List) {
        jobsList = response['recommendations'] as List<dynamic>;
      } else if (response['jobs'] is List) {
        jobsList = response['jobs'] as List<dynamic>;
      }
    } catch (e) {
      debugPrint('=== HOME ERROR: recommendations: $e ===');
    }

    final interviewsCount = await _fetchConfirmedInterviewsCount();

    if (totalApps == 0 && pendingApps == 0) {
      final applicationCounts = await _fetchApplicationCounts();
      pendingApps = applicationCounts.pending;
      totalApps = applicationCounts.total;
    }

    final statsList = [
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

  Future<int> _fetchConfirmedInterviewsCount() async {
    try {
      debugPrint('=== HOME: Fetching ${ApiConstants.candidateInterviews} ===');
      final response = await _apiClient.get(ApiConstants.candidateInterviews);
      final interviews = _extractInterviews(response);
      final count = interviews
          .where((interview) => interview.status == InterviewStatus.completed)
          .length;
      debugPrint('=== HOME: confirmed interviews count=$count ===');
      return count;
    } catch (e) {
      debugPrint('=== HOME ERROR: interviews: $e ===');
      return 0;
    }
  }

  List<InterviewModel> _extractInterviews(Map<String, dynamic> response) {
    final data = response['data'];
    final rawInterviews = data is Map
        ? data['interviews']
        : response['interviews'];

    if (rawInterviews is! List) return const [];

    return rawInterviews
        .whereType<Map>()
        .map((item) => InterviewModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<_ApplicationCounts> _fetchApplicationCounts() async {
    try {
      final response = await _apiClient.get(ApiConstants.applications);
      final apps = _extractApplications(response);
      var pending = 0;

      for (final app in apps) {
        final statusValues = [
          app['status'],
          app['statusId'],
          app['statusValue'],
          app['statusName'],
          app['applicationStatus'],
        ];

        if (statusValues.any((value) => _isPendingReviewStatus('$value'))) {
          pending++;
        }
      }

      final total = apps.isNotEmpty
          ? apps.length
          : _toInt(response['totalCount']);
      debugPrint('=== HOME: totalApps=$total, pendingApps=$pending ===');
      return _ApplicationCounts(total: total, pending: pending);
    } catch (e) {
      debugPrint('=== HOME ERROR: applications: $e ===');
      return const _ApplicationCounts(total: 0, pending: 0);
    }
  }

  List<Map<String, dynamic>> _extractApplications(
    Map<String, dynamic> response,
  ) {
    final data = response['data'];
    final rawApplications = data is List
        ? data
        : data is Map
        ? data['applications'] ?? data['items']
        : response['applications'];

    if (rawApplications is! List) return const [];

    return rawApplications
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

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

    if (normalized.isEmpty || normalized == 'null') return false;
    return normalized == '1' ||
        normalized == 'pendingreview' ||
        normalized.contains('pending') ||
        normalized.contains('review');
  }
}

class _ApplicationCounts {
  final int total;
  final int pending;

  const _ApplicationCounts({required this.total, required this.pending});
}
