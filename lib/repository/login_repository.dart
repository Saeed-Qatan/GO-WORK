import 'package:gowork/core/constants/api_constants.dart';
import 'package:gowork/utils/api_storage.dart';
import '../model/auth/login_model.dart';
import '../utils/local_storage.dart';

class LoginRepository {
  final ApiClient _apiClient = ApiClient();
  final LocalStorage _storage = LocalStorage();

  Future<LoginResponse> login(String email, String password) async {
    final request = LoginRequest(email: email, password: password);

    final response = await _apiClient.post(
      ApiConstants.login,
      request.toJson(),
    );

    print('--- RAW LOGIN RESPONSE ---');
    print(response);

    final loginResponse = LoginResponse.fromJson(response);

    // Save token and userId to local storage
    if (loginResponse.token.isNotEmpty) {
      await _storage.saveString('token', loginResponse.token);
      await _storage.saveString('userId', loginResponse.userId);
    }

    return loginResponse;
  }
}
