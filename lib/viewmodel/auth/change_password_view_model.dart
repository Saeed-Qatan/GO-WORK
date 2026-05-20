import 'package:flutter/material.dart';
import 'package:gowork/repository/change_password_repository.dart';
import 'package:gowork/utils/app_error_parser.dart';

class ChangePasswordViewModel extends ChangeNotifier {
  final ChangePasswordRepository _repository = ChangePasswordRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    if (newPassword != confirmPassword) {
      _errorMessage = 'كلمة المرور الجديدة غير متطابقة';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    try {
      final response = await _repository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      if (response['success'] == true) {
        _successMessage =
            response['data']?['message'] ?? 'تم تغيير كلمة المرور بنجاح';
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = AppErrorParser.parseResponseData(
          response,
          fallbackMessage: 'فشل تغيير كلمة المرور',
        );
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = AppErrorParser.parse(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
