import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gowork/services/auth/email_verification_service.dart';
import 'package:gowork/utils/navigations.dart';
import 'package:gowork/utils/snackbar_service.dart';

class EmailVerificationViewModel extends ChangeNotifier {
  final EmailVerificationService _service = EmailVerificationService();
  String? email;

  final List<TextEditingController> controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());

  bool isLoading = false;
  int countdown = 60;
  Timer? _timer;
  bool _timerStarted = false;

  void setArgs(String email) {
    if (this.email == null) {
      this.email = email;
      if (!_timerStarted) {
        startTimer();
        _timerStarted = true;
      }
    }
  }

  void startTimer() {
    countdown = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown > 0) {
        countdown--;
        notifyListeners();
      } else {
        timer.cancel();
      }
    });
    notifyListeners();
  }

  String get code => controllers.map((c) => c.text).join();

  Future<void> verify(BuildContext context) async {
    if (code.length < 6) {
      SnackbarService.showWarning('الرجاء إدخال الرمز كاملاً');
      return;
    }
    if (email == null) return;

    isLoading = true;
    notifyListeners();
    try {
      await _service.verifyEmail(email!, code);
      if (context.mounted) {
        SnackbarService.showSuccess('تم التحقق بنجاح');
        NavigationService.pushNamedAndRemoveUntil(Routes.login);
      }
    } catch (e) {
      SnackbarService.showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resend(BuildContext context) async {
    if (countdown > 0) return;
    if (email == null) return;

    isLoading = true;
    notifyListeners();

    try {
      await _service.resendCode(email!);
      startTimer();
      if (context.mounted) {
        SnackbarService.showInfo('تم إعادة إرسال الرمز بنجاح');
      }
    } catch (e) {
      if (context.mounted) {
        SnackbarService.showError(e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
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

  @override
  void dispose() {
    for (var c in controllers) {
      c.dispose();
    }
    for (var f in focusNodes) {
      f.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }
}
