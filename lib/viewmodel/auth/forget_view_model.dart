import 'package:flutter/material.dart';

enum ForgetState { idle, loading, success, error }

class ForgetViewModel extends ChangeNotifier {
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

  Future<void> submit() async {
    if (!canSubmit) return;

    _state = ForgetState.loading;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      final email = emailController.text.trim();

      // Basic email validation
      if (!email.contains('@')) {
        throw Exception('البريد الإلكتروني غير صالح');
      }

      _state = ForgetState.success;
    } catch (e) {
      _state = ForgetState.error;
      _error = e.toString().replaceAll('Exception: ', '');
    }

    notifyListeners();
  }

  @override
  void dispose() {
    emailController.removeListener(_onEmailChanged);
    emailController.dispose();
    super.dispose();
  }
}
