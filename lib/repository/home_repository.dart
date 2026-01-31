import '../model/home_model.dart';
import '../services/home_service.dart';

class HomeRepository {
  final HomeService _service = HomeService();

  // Cache for home data to avoid duplicate API calls
  Map<String, dynamic>? _cachedData;

  /// Fetch all home data at once
  Future<Map<String, dynamic>> _fetchHomeData() async {
    if (_cachedData != null) {
      return _cachedData!;
    }

    try {
      _cachedData = await _service.getHomeData();
      return _cachedData!;
    } catch (e) {
      // Return empty structure on error
      return {'stats': [], 'jobs': []};
    }
  }

  /// Clear cache (call when refreshing data)
  void clearCache() {
    _cachedData = null;
  }

  Future<List<StatModel>> getStats() async {
    final data = await _fetchHomeData();
    if (data['stats'] != null) {
      return (data['stats'] as List).map((e) => StatModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<List<JobModel>> getRecommendedJobs() async {
    final data = await _fetchHomeData();
    if (data['jobs'] != null) {
      return (data['jobs'] as List).map((e) => JobModel.fromJson(e)).toList();
    }
    return [];
  }
}
