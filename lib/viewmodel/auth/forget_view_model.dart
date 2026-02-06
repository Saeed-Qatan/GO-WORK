import 'package:flutter/material.dart';
import 'package:gowork/repository/forget_repository.dart';
import 'package:gowork/utils/navigations.dart';
import 'package:gowork/view/auth/reset_password_view.dart';

enum ForgetState { idle, loading, success, error }

class ForgetViewModel extends ChangeNotifier {
  final ForgetRepository _repository = ForgetRepository();
  final TextEditingController emailController = TextEditingController();

  ForgetState _state = ForgetState.idle;
  ForgetState get state => _state;

  String? _error;
  String? get error => _error;

  bool get isLoading => _state == ForgetState.loading;

  bool get canSubmit {
    final email = emailController.text.trim();
    return email.isNotEmpty && !isLoading;
  }

  ForgetViewModel() {
    emailController.addListener(_onEmailChanged);
  }

  void _onEmailChanged() {
    notifyListeners();
  }

  Future<void> submit(BuildContext context) async {
    if (!canSubmit) return;

    _state = ForgetState.loading;
    _error = null;
    notifyListeners();

    try {
      final email = emailController.text.trim();

      // Basic email validation
      if (!email.contains('@')) {
        throw Exception('البريد الإلكتروني غير صالح');
      }

      await _repository.forgetPassword(email);

      _state = ForgetState.success;
      notifyListeners();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إرسال كود التحقق إلى بريدك الإلكتروني'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate to Reset Password Page
        NavigationService.pushReplacement(ResetPasswordView(email: email));
      }
    } catch (e) {
      _state = ForgetState.error;
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  @override
  void dispose() {
    emailController.removeListener(_onEmailChanged);
    emailController.dispose();
    super.dispose();
  }
}
