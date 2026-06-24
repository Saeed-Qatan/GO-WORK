import 'package:gowork/core/constants/api_constants.dart';
import 'package:gowork/utils/api_storage.dart';

class ChangePasswordService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final body = {'OldPassword': currentPassword, 'NewPassword': newPassword};

    final response = await _apiClient.patch(ApiConstants.changePassword, body);

    return response;
  }
}
