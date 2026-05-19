import 'package:gowork/core/constants/api_constants.dart';
import 'package:gowork/model/auth/reset_password_model.dart';
import 'package:gowork/utils/api_storage.dart';

class ResetPasswordRepository {
  final ApiClient _apiClient = ApiClient();

  Future<void> resetPassword(ResetPasswordRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.resetPassword,
        request.toJson(),
        skipAuth: true,
      );

      if (response.containsKey('success') && response['success'] != true) {
        throw Exception(response['message'] ?? 'Password reset failed');
      }
    } catch (e) {
      rethrow;
    }
  }
}
