import 'package:flutter/material.dart';
import '../../repository/login_repository.dart';
import 'package:gowork/utils/local_storage.dart';

class LoginViewModel extends ChangeNotifier {
  final LoginRepository _repository = LoginRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _rememberMe = false;
  bool get rememberMe => _rememberMe;

  void toggleRememberMe(bool? value) {
    _rememberMe = value ?? false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.login(email, password);

      await LocalStorage().saveString('token', response.token);
      await LocalStorage().saveString('userId', response.userId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
