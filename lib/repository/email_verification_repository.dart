import 'package:gowork/core/constants/api_constants.dart';
import 'package:gowork/utils/api_storage.dart';

class EmailVerificationRepository {
  final ApiClient _apiClient = ApiClient();

  Future<void> verifyEmail(String email, String code) async {
    try {
      final response = await _apiClient.post(ApiConstants.verifyEmail, {
        'email': email,
        'emailConfirmationCode': code,
      });

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Verification failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resendCode(String email) async {
    try {
      final response = await _apiClient.post(ApiConstants.resendCode, {
        'email': email,
      });
      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Resend failed');
      }
    } catch (e) {
      rethrow;
    }
  }
}
