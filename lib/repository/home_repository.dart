import 'package:flutter/foundation.dart';
import '../model/home/home_model.dart';
import '../services/home_service.dart';

/// Repository that provides fresh home data to the ViewModel.
class HomeRepository {
  final HomeService _service;

  // In-flight future to prevent concurrent duplicate requests
  Future<Map<String, dynamic>>? _activeFetch;

  HomeRepository({HomeService? service}) : _service = service ?? HomeService();

  /// Fetch all home data at once.
  ///
  /// This intentionally does not persist results after completion. Home counts,
  /// especially interviews, must reflect backend status changes immediately.
  Future<Map<String, dynamic>> _fetchHomeData() async {
    // If a fetch is already in progress, wait for it instead of duplicating
    if (_activeFetch != null) {
      return _activeFetch!;
    }

    _activeFetch = _service.getHomeData();
    try {
      return await _activeFetch!;
    } finally {
      _activeFetch = null;
    }
  }

  /// Cancels the shared in-flight reference so the next call starts fresh.
  void clearCache() {
    _activeFetch = null;
  }

  /// Returns parsed stat models from fresh home data.
  Future<List<StatModel>> getStats() async {
    final data = await _fetchHomeData();
    if (data['stats'] != null && data['stats'] is List) {
      return (data['stats'] as List)
          .map((e) => StatModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Returns parsed job models from fresh home data.
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

  /// Returns the user's full name from fresh home data.
  Future<String> getUserName() async {
    final data = await _fetchHomeData();
    return data['seekerFullName']?.toString() ?? '';
  }

  /// Returns the user's profile photo URL from fresh home data.
  Future<String> getProfilePhoto() async {
    final data = await _fetchHomeData();
    return data['seekerProfilePhoto']?.toString() ?? '';
  }
}
