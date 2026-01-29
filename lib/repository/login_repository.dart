import '../model/auth/login_model.dart';
import '../services/auth/login_service.dart';

class LoginRepository {
  final LoginService _loginService = LoginService();

  Future<LoginResponse> login(String email, String password) async {
    final request = LoginRequest(email: email, password: password);
    return await _loginService.login(request);
  }
}
