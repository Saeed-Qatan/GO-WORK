import 'package:gowork/core/constants/api_constants.dart';
import 'package:gowork/utils/api_storage.dart';
import 'package:gowork/utils/app_error_parser.dart';

class EmailVerificationRepository {
  final ApiClient _apiClient = ApiClient();

  Future<void> verifyEmail(String email, String code) async {
    try {
      final response = await _apiClient.post(ApiConstants.verifyEmail, {
        'email': email,
        'emailConfirmationCode': code,
      }, skipAuth: true);

      if (response['success'] != true) {
        throw Exception(
          AppErrorParser.parseResponseData(
            response,
            fallbackMessage: 'تعذر التحقق من الكود، يرجى المحاولة مرة أخرى',
          ),
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resendCode(String email) async {
    try {
      final response = await _apiClient.post(ApiConstants.resendOtp, {
        'email': email,
      }, skipAuth: true);
      if (response['success'] != true) {
        throw Exception(
          AppErrorParser.parseResponseData(
            response,
            fallbackMessage: 'تعذر إعادة إرسال الكود، يرجى المحاولة مرة أخرى',
          ),
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
