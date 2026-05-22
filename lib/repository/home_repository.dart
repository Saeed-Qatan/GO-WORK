import 'package:flutter/foundation.dart';
import '../model/home_model.dart';
import '../services/home_service.dart';

/// Repository that caches home data and provides it to the ViewModel.
class HomeRepository {
  final HomeService _service = HomeService();

  // Cache for home data to avoid duplicate API calls
  Map<String, dynamic>? _cachedData;

  // In-flight future to prevent concurrent duplicate requests
  Future<Map<String, dynamic>>? _activeFetch;

  /// Fetch all home data at once (single request, shared across callers).
  Future<Map<String, dynamic>> _fetchHomeData() async {
    if (_cachedData != null) {
      return _cachedData!;
    }

    // If a fetch is already in progress, wait for it instead of duplicating
    if (_activeFetch != null) {
      return _activeFetch!;
    }

    _activeFetch = _service.getHomeData();
    try {
      _cachedData = await _activeFetch;
      return _cachedData!;
    } finally {
      _activeFetch = null;
    }
  }

  /// Clear cache (call when refreshing data).
  void clearCache() {
    _cachedData = null;
    _activeFetch = null;
  }

  /// Returns parsed stat models from the cached home data.
  Future<List<StatModel>> getStats() async {
    final data = await _fetchHomeData();
    if (data['stats'] != null && data['stats'] is List) {
      return (data['stats'] as List)
          .map((e) => StatModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Returns parsed job models from the cached home data.
  Future<List<JobModel>> getRecommendedJobs() async {
    final data = await _fetchHomeData();
    if (data['jobs'] != null && data['jobs'] is List) {
      final jobs = <JobModel>[];
      for (var e in (data['jobs'] as List)) {
        try {
          jobs.add(JobModel.fromJson(e as Map<String, dynamic>));
        } catch (err) {
          debugPrint('Error parsing job: $err');
        }
      }
      return jobs;
    }
    return [];
  }

  /// Returns the user's full name from the cached home data.
  Future<String> getUserName() async {
    final data = await _fetchHomeData();
    return data['seekerFullName']?.toString() ?? '';
  }

  /// Returns the user's profile photo URL from the cached home data.
  Future<String> getProfilePhoto() async {
    final data = await _fetchHomeData();
    return data['seekerProfilePhoto']?.toString() ?? '';
  }
}
