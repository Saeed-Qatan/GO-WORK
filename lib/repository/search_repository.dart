import 'package:flutter/foundation.dart';
import '../core/constants/api_constants.dart';
import '../model/home_model.dart';
import '../utils/api_storage.dart';
import '../utils/status_translator.dart';

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
      final queryParams = <String, String>{};
      if (query != null && query.trim().isNotEmpty) {
        queryParams['query'] = query.trim();
      }
      if (category != null && category.trim().isNotEmpty) {
        queryParams['category'] = category.trim();
      }
      if (workMode != null && workMode.trim().isNotEmpty) {
        queryParams['locationType'] = workMode.trim();
      }
      if (type != null && type.trim().isNotEmpty) {
        queryParams['type'] = type.trim();
      }
      if (country != null && country.trim().isNotEmpty) {
        queryParams['country'] = country.trim();
      }

      final queryString = queryParams.isEmpty
          ? ''
          : '?${queryParams.entries.map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}').join('&')}';

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

    return fetchedJobs.where((job) {
      final trimmedQuery = query?.trim().toLowerCase();
      final matchesQuery =
          trimmedQuery == null ||
          trimmedQuery.isEmpty ||
          job.title.toLowerCase().contains(trimmedQuery) ||
          job.company.toLowerCase().contains(trimmedQuery);

      final matchesCategory =
          _isEmptyFilter(category) || _matchesFilter(job.category, category!);
      final matchesLocation =
          _isEmptyFilter(workMode) || _matchesFilter(job.workMode, workMode!);
      final matchesCountry =
          _isEmptyFilter(country) || _matchesFilter(job.country, country!);
      final matchesType =
          _isEmptyFilter(type) || _matchesFilter(job.type, type!);

      return matchesQuery &&
          matchesCategory &&
          matchesLocation &&
          matchesCountry &&
          matchesType;
    }).toList();
  }

  bool _isEmptyFilter(String? value) => value == null || value.trim().isEmpty;

  bool _matchesFilter(String value, String filter) {
    final valueVariants = _filterVariants(value);
    final filterVariants = _filterVariants(filter);
    return valueVariants.any(filterVariants.contains);
  }

  Set<String> _filterVariants(String value) {
    return {
      StatusTranslator.normalize(value),
      StatusTranslator.normalize(StatusTranslator.workModeLabel(value)),
      StatusTranslator.normalize(StatusTranslator.jobTypeLabel(value)),
    }..remove('');
  }
}
