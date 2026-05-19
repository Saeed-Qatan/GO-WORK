import 'package:flutter/foundation.dart';
import '../core/constants/api_constants.dart';
import '../model/home_model.dart';
import '../utils/api_storage.dart';

class SearchRepository {
  final ApiClient _apiClient = ApiClient();

  Future<List<JobModel>> searchJobs({
    String? query,
    String? category,
    String? workMode,
    String? type,
    String? country,
  }) async {
    List<JobModel> fetchedJobs = [];

    try {
      // Construct query parameters
      final Map<String, String> queryParams = {};
      if (query != null && query.isNotEmpty) {
        queryParams['query'] = query;
      }
      if (category != null && category != 'جميع المجالات') {
        queryParams['category'] = category;
      }
      if (workMode != null && workMode != 'الكل') {
        queryParams['locationType'] = workMode;
      }
      if (type != null && type != 'الكل') {
        queryParams['type'] = type;
      }
      if (country != null && country != 'الكل') {
        queryParams['country'] = country;
      }

      String queryString = '';
      if (queryParams.isNotEmpty) {
        queryString =
            '?${queryParams.entries.map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}').join('&')}';
      }

      // Use the searchJobs endpoint
      final response = await _apiClient.get(
        '${ApiConstants.searchJobs}$queryString',
      );

      if (response.containsKey('data')) {
        final data = response['data'] as Map<String, dynamic>;
        if (data.containsKey('jobs')) {
          final listMap = data['jobs'] as List<dynamic>? ?? [];
          fetchedJobs = listMap
              .map((item) => JobModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else if (data.containsKey('recommendations')) {
          final listMap = data['recommendations'] as List<dynamic>? ?? [];
          fetchedJobs = listMap
              .map((item) => JobModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      } else if (response.containsKey('jobs')) {
        final listMap = response['jobs'] as List<dynamic>? ?? [];
        fetchedJobs = listMap
            .map((item) => JobModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('Failed to fetch jobs for search: $e');
    }

    // Apply local filtering logic
    return fetchedJobs.where((job) {
      final matchesQuery =
          query == null ||
          query.isEmpty ||
          job.title.toLowerCase().contains(query.toLowerCase()) ||
          job.company.toLowerCase().contains(query.toLowerCase());

      final matchesCategory =
          category == null ||
          category == 'جميع المجالات' ||
          _matchesFilter(job.category, category);
      final matchesLocation =
          workMode == null ||
          workMode == 'الكل' ||
          _matchesFilter(job.workMode, workMode);
      final matchesCountry =
          country == null ||
          country == 'الكل' ||
          _matchesFilter(job.country, country);
      final matchesType =
          type == null || type == 'الكل' || _matchesFilter(job.type, type);

      return matchesQuery &&
          matchesCategory &&
          matchesLocation &&
          matchesCountry &&
          matchesType;
    }).toList();
  }

  bool _matchesFilter(String value, String filter) {
    return value.trim().toLowerCase() == filter.trim().toLowerCase();
  }
}
