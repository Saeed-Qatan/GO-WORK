
import 'package:flutter/material.dart';
import 'package:gowork/repository/change_password_repository.dart';

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
        _successMessage = response['data']?['message'] ?? 'تم تغيير كلمة المرور بنجاح';
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'فشل تغيير كلمة المرور';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = _parseError(e.toString());
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  String _parseError(String error) {
    if (error.contains('400')) {
      return 'كلمة المرور الحالية غير صحيحة أو البيانات غير مكتملة';
    }
    return error.replaceAll('Exception: ', '');
  }
}