import 'package:gowork/utils/api_storage.dart';
import 'package:gowork/core/constants/api_constants.dart';

/// Service: يتولى التواصل المباشر مع API لحذف حساب المرشح
class DeleteAccountService {
  final ApiClient _apiClient = ApiClient();

  /// POST /Account/Candidate/DeleteAccount
  /// لا يحتاج request body — فقط Bearer Token في الـ Header
  Future<Map<String, dynamic>> deleteAccount() async {
    return await _apiClient.post(
      ApiConstants.deleteAccount,
      {}, // No body required
    );
  }
}
