import '../model/auth/login_model.dart';
import '../services/auth/login_service.dart';
import '../utils/local_storage.dart';

class LoginRepository {
  final LoginService _loginService = LoginService();
  final LocalStorage _storage = LocalStorage();

  Future<LoginResponse> login(String email, String password) async {
    final request = LoginRequest(email: email, password: password);
    final response = await _loginService.login(request);

    // Save token and userId to local storage
    if (response.token.isNotEmpty) {
      await _storage.saveString('token', response.token);
      await _storage.saveString('userId', response.userId);
    }

    return response;
  }
}
