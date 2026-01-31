import 'package:gowork/utils/api_storage.dart';
import 'package:gowork/core/constants/api_constants.dart';

class ProfileService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> getUserProfile() async {
    return await _apiClient.get(ApiConstants.profile);
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    return await _apiClient.put(ApiConstants.updateProfile, data);
  }
}
