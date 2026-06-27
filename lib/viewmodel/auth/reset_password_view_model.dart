import 'package:flutter/material.dart';
import 'package:gowork/model/auth/reset_password_model.dart';
import 'package:gowork/repository/reset_password_repository.dart';
import 'package:go_router/go_router.dart';
import 'package:gowork/routing/app_router.dart';
import 'package:gowork/utils/snackbar_service.dart';
import 'package:gowork/utils/app_error_parser.dart';

enum ResetState { idle, loading, success, error }

class ResetPasswordViewModel extends ChangeNotifier {
  final ResetPasswordRepository _repository = ResetPasswordRepository();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final String email;
  final String code;

  ResetState _state = ResetState.idle;
  ResetState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _state == ResetState.loading;

  ResetPasswordViewModel({required this.email, required this.code});

  String? validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'الرجاء إدخال كلمة المرور';
    if (v.length < 6) return 'كلمة المرور قصيرة جداً';

    bool hasUppercase = v.contains(RegExp(r'[A-Z]'));
    bool hasDigits = v.contains(RegExp(r'[0-9]'));
    bool isEnglish = v.contains(RegExp(r'^[a-zA-Z0-9!@#$%^&*(),.?":{}|<>]+$'));

    if (!isEnglish) return 'كلمة المرور يجب أن تكون باللغة الإنجليزية';
    if (!hasUppercase) return 'يجب أن تحتوي على حرف كبير واحد على الأقل';
    if (!hasDigits) return 'يجب أن تحتوي على رقم واحد على الأقل';

    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value != passwordController.text) {
      return 'كلمات المرور غير متطابقة';
    }
    return null;
  }

  Future<void> submit(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    _state = ResetState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = ResetPasswordRequest(
        email: email,
        code: code,
        newPassword: passwordController.text,
        confirmPassword: confirmPasswordController.text,
      );

      await _repository.resetPassword(request);

      _state = ResetState.success;
      notifyListeners();

      if (context.mounted) {
        SnackbarService.showPasswordResetSuccess('تم تغيير كلمة المرور بنجاح');
        context.go(AppRoutes.login);
      }
    } catch (e) {
      _state = ResetState.error;
      _errorMessage = AppErrorParser.parse(e);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
