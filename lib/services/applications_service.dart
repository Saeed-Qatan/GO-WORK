import 'package:gowork/core/constants/api_constants.dart';
import 'package:gowork/utils/api_storage.dart';

class ApplicationsService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> getApplications() async {
    return await _apiClient.get(ApiConstants.applications);
  }
}
