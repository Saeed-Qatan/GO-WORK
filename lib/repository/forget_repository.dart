import 'package:gowork/core/constants/api_constants.dart';
import 'package:gowork/utils/api_storage.dart';

class ForgetRepository {
  final ApiClient _apiClient = ApiClient();

  Future<void> forgetPassword(String email) async {
    try {
      final response = await _apiClient.post(ApiConstants.forgetPassword, {
        'email': email,
      });

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to send reset link');
      }
    } catch (e) {
      rethrow;
    }
  }
}
