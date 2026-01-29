import '../../utils/api_storage.dart';
import '../../model/auth/login_model.dart';
import '../../core/constants/api_constants.dart';

class LoginService {
  final ApiClient _apiClient = ApiClient();

  Future<LoginResponse> login(LoginRequest request) async {
    final response = await _apiClient.post(
      ApiConstants.login,
      request.toJson(),
    );
    return LoginResponse.fromJson(response);
  }
}
