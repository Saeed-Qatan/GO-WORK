import 'package:gowork/services/auth/change_password_service.dart';

class ChangePasswordRepository {
  final ChangePasswordService _service = ChangePasswordService();

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _service.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      // We expect response to have statusCode: 200 and success: true based on user example
      // It also might throw an exception from ApiClient if it fails.
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
