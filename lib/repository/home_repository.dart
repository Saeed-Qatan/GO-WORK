import '../model/home_model.dart';
import '../services/home/home_service.dart';

class HomeRepository {
  final HomeService _service = HomeService();

  Future<List<StatModel>> getStats() async {
    // For now returning mock/local data via Service or just mock here if API not ready.
    // But goal is to use ApiClient.
    // Let's assume the /home endpoint returns: { "stats": [...], "jobs": [...] }
    final data = await _service.getHomeData();
    if (data['stats'] != null) {
      return (data['stats'] as List).map((e) => StatModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<List<JobModel>> getRecommendedJobs() async {
    final data = await _service.getHomeData();
    if (data['jobs'] != null) {
      return (data['jobs'] as List).map((e) => JobModel.fromJson(e)).toList();
    }
    return [];
  }
}
