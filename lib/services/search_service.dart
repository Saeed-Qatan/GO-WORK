import 'package:flutter/foundation.dart';

import '../core/constants/api_constants.dart';
import '../utils/api_storage.dart';

class SearchService {
  final ApiClient _apiClient;

  SearchService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<List<dynamic>> searchJobs({
    String? query,
    String? categoryId,
    String? countryId,
    String? locationType,
    String? jobType,
  }) async {
    final queryParams = <String, String>{};
    _addParam(queryParams, 'search', query);
    // ✅ أسماء الـ query keys مؤكدة من الباك إند: categories, countries,
    // jobTypes, locationTypes (plural camelCase — مطابقة لأسماء endpoints
    // الفلاتر: Jobs/countries, Jobs/job-types, Jobs/location-types).
    // categories/countries: القيمة id رقمي (جدول حقيقي بقاعدة البيانات).
    _addParam(queryParams, 'categories', categoryId);
    _addParam(queryParams, 'countries', countryId);
    // jobTypes/locationTypes: القيمة اسم الـ enum الإنجليزي كما هو
    // (FullTime, PartTime, Contract, Internship / OnSite, Remote, Hybrid).
    _addParam(queryParams, 'locationTypes', locationType);
    _addParam(queryParams, 'jobTypes', jobType);

    final endpoint = _buildEndpoint(queryParams);
    _debugLog('=== SEARCH SERVICE: GET $endpoint ===');
    _debugLog('=== SEARCH SERVICE: params=$queryParams ===');

    try {
      final response = await _apiClient.get(endpoint);
      _debugLog(
        '=== SEARCH SERVICE: response keys=${response.keys.toList()} ===',
      );
      _debugLog(
        '=== SEARCH SERVICE: statusCode=${response['statusCode']}, success=${response['success']} ===',
      );

      final jobs = _extractJobsList(response);
      final data = response['data'];
      if (data is Map) {
        _debugLog(
          '=== SEARCH SERVICE: page=${data['page']}, pageSize=${data['pageSize']}, totalCount=${data['totalCount']}, hasNextPage=${data['hasNextPage']} ===',
        );
      }
      _debugLog('=== SEARCH SERVICE: jobs count=${jobs.length} ===');

      return jobs;
    } catch (e) {
      _debugLog('=== SEARCH SERVICE ERROR (${e.runtimeType}): $e ===');
      rethrow;
    }
  }

  void _addParam(Map<String, String> params, String key, String? value) {
    final trimmed = value?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      params[key] = trimmed;
    }
  }

  String _buildEndpoint(Map<String, String> queryParams) {
    if (queryParams.isEmpty) return ApiConstants.searchJobs;

    final queryString = Uri(queryParameters: queryParams).query;
    return '${ApiConstants.searchJobs}?$queryString';
  }

  List<dynamic> _extractJobsList(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is Map) {
      final jobs = data['jobs'];
      if (jobs is List) return jobs;
    }

    if (data is List) return data;

    final fallbackJobs = response['jobs'];
    if (fallbackJobs is List) return fallbackJobs;

    return const [];
  }

  void _debugLog(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }
}