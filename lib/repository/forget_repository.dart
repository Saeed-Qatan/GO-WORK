import 'package:gowork/core/constants/api_constants.dart';
import 'package:gowork/utils/api_storage.dart';
import 'package:gowork/utils/app_error_parser.dart';

class ForgetRepository {
  final ApiClient _apiClient = ApiClient();

  Future<void> forgetPassword(String email) async {
    try {
      final response = await _apiClient.post(ApiConstants.forgetPassword, {
        'email': email,
      }, skipAuth: true);

      if (response['success'] != true) {
        throw Exception(
          AppErrorParser.parseResponseData(
            response,
            fallbackMessage: 'تعذر إرسال كود التحقق، يرجى المحاولة مرة أخرى',
          ),
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
