import 'package:flutter/foundation.dart';
import '../core/constants/api_constants.dart';
import '../model/home_model.dart';
import '../utils/api_storage.dart';

class JobService {
  final ApiClient _apiClient = ApiClient();

  /// Fetch detailed information for a specific job by its ID.
  Future<JobModel?> getJobById(dynamic jobId) async {
    try {
      final response = await _apiClient.get('${ApiConstants.jobDetails}/$jobId');
      
      // Depending on how your backend wraps the single entity:
      // It might return { "data": { ... } } or just { "id": ... } directly.
      if (response.containsKey('data') && response['data'] != null) {
        return JobModel.fromJson(response['data']);
      } else if (response.containsKey('job') && response['job'] != null) {
        return JobModel.fromJson(response['job']);
      } else if (response.isNotEmpty) {
        return JobModel.fromJson(response);
      }
      return null;
    } catch (e) {
      debugPrint('Failed to fetch job with ID $jobId: $e');
      throw Exception('Failed to fetch job details: $e');
    }
  }
}
