import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gowork/services/auth/email_verification_service.dart';
import 'package:gowork/utils/snackbar_service.dart';
import 'package:go_router/go_router.dart';
import 'package:gowork/routing/app_router.dart';

class EmailVerificationViewModel extends ChangeNotifier {
  final List<TextEditingController> controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());

  String? email;
  bool isLoading = false;
  int countdown = 60;
  Timer? _timer;

  EmailVerificationViewModel() {
    _startTimer();
  }

  void setArgs(String email) {
    this.email = email;
    notifyListeners();
  }

  void _startTimer() {
    countdown = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown > 0) {
        countdown--;
        notifyListeners();
      } else {
        _timer?.cancel();
      }
    });
  }

  void onCodeChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
    notifyListeners();
  }

  Future<void> verify(BuildContext context) async {
    final code = controllers.map((c) => c.text).join();
    if (code.length < 6) {
      SnackbarService.showError('الرجاء إدخال الرمز المكون من 6 أرقام');
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      await EmailVerificationService().verifyEmail(email!, code);
      SnackbarService.showSuccess('تم تفعيل الحساب بنجاح');
      if (context.mounted) {
        context.go(AppRoutes.login);
      }
    } catch (e) {
      SnackbarService.showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resend(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    try {
      await EmailVerificationService().resendCode(email!);
      _startTimer();
      SnackbarService.showSuccess('تم إعادة إرسال الرمز');
    } catch (e) {
      SnackbarService.showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in controllers) {
      c.dispose();
    }
    for (var f in focusNodes) {
      f.dispose();
    }
    super.dispose();
  }
}
