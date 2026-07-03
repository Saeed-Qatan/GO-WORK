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
    String? jobLocationTypeId,
    String? jobTypeId,
  }) async {
    final queryParams = <String, String>{};
    _addParam(queryParams, 'search', query);
    // ✅ countryId: مؤكد فعليًا بالاختبار المباشر — GET
    // /Jobs/search?countryId=122 رجّع بالضبط نفس وظائف السعودية (id 122)،
    // تطابق رياضي 100%. القيمة id رقمي.
    _addParam(queryParams, 'countryId', countryId);
    // ✅ categoryId: مؤكد فعليًا — GET /Jobs/search?categoryId=101 رجّع 39
    // نتيجة، كلها فئة "تطوير البرمجيات" بدون استثناء. القيمة id رقمي.
    _addParam(queryParams, 'categoryId', categoryId);
    // ✅ jobTypeId: مؤكد فعليًا بالاختبار المباشر (jobTypeId=1 = FullTime).
    _addParam(queryParams, 'jobTypeId', jobTypeId);
    // ✅ jobLocationTypeId: مؤكد فعليًا بالاختبار المباشر
    // (jobLocationTypeId=1 = OnSite). الاسم الحقيقي بالباك إند
    // "JobLocationType" مو "LocationType" العادي — مطابق لنمط JobType،
    // وهذا نفس ما كان JobModel.fromJson يتحقق منه أصلاً
    // (json['jobLocationType'] قبل json['locationType']).
    _addParam(queryParams, 'jobLocationTypeId', jobLocationTypeId);
    // 🎉 الأربعة فلاتر مؤكدين فعليًا على السيرفر الحقيقي. الفلترة المحلية
    // بالـ ViewModel أُزيلت بثقة كاملة.

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