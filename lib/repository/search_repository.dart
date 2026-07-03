import 'package:flutter/foundation.dart';
import '../model/home/home_model.dart';
import '../services/search_service.dart';
import '../utils/api_storage.dart';

class SearchRepository {
  final SearchService _service;

  SearchRepository({SearchService? service, ApiClient? apiClient})
    : _service = service ?? SearchService(apiClient: apiClient);

  Future<List<JobModel>> searchJobs({
    String? query,
    String? categoryId,
    String? countryId,
    String? jobLocationTypeId,
    String? jobTypeId,
  }) async {
    try {
      final rawJobs = await _service.searchJobs(
        query: query,
        categoryId: categoryId,
        countryId: countryId,
        jobLocationTypeId: jobLocationTypeId,
        jobTypeId: jobTypeId,
      );
      final jobs = _parseJobs(rawJobs);
      _debugLog('Search repository parsed count: ${jobs.length}');
      return jobs;
    } catch (e) {
      _debugLog('Failed to fetch jobs for search (${e.runtimeType}): $e');
      rethrow;
    }
  }

  List<JobModel> _parseJobs(List<dynamic> rawJobs) {
    final jobs = <JobModel>[];
    for (final item in rawJobs) {
      final jobMap = _asMap(item);
      if (jobMap == null) {
        _debugLog('Skipping invalid search job item: $item');
        continue;
      }

      try {
        jobs.add(JobModel.fromJson(jobMap));
      } catch (e) {
        _debugLog('Failed to parse search job item: $e');
      }
    }
    return jobs;
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  void _debugLog(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }
}