import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gowork/main.dart';
import 'package:gowork/model/auth/email_verification_args.dart';
import 'package:gowork/repository/login_repository.dart';
import 'package:gowork/repository/profile_repository.dart';
import 'package:gowork/services/auth/email_verification_service.dart';
import 'package:gowork/utils/snackbar_service.dart';
import 'package:gowork/utils/app_error_parser.dart';
import 'package:go_router/go_router.dart';
import 'package:gowork/routing/app_router.dart';

class EmailVerificationViewModel extends ChangeNotifier {
  final List<TextEditingController> controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());

  String? email;
  String? password;
  bool isLoading = false;
  int countdown = 60;
  Timer? _timer;
  final LoginRepository _loginRepository = LoginRepository();
  final ProfileRepository _profileRepository = ProfileRepository();

  EmailVerificationViewModel() {
    _startTimer();
  }

  void setArgs(Object args) {
    if (args is EmailVerificationArgs) {
      email = args.email;
      password = args.password;
    } else if (args is String) {
      email = args;
      password = null;
    }
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
        await _loginAfterVerification(context);
      }
    } catch (e) {
      SnackbarService.showError(AppErrorParser.parse(e));
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loginAfterVerification(BuildContext context) async {
    final emailValue = email?.trim();
    final passwordValue = password;
    if (emailValue == null ||
        emailValue.isEmpty ||
        passwordValue == null ||
        passwordValue.isEmpty) {
      context.go(AppRoutes.login);
      return;
    }

    try {
      await _loginRepository.login(emailValue, passwordValue);
      await pushNotificationService.registerCurrentToken();
      try {
        final profile = await _profileRepository.getUserProfile();
        await notificationTopicService.subscribeUserTopics(
          categoryId: profile.categoryId,
        );
      } catch (_) {
        await notificationTopicService.subscribeUserTopics(categoryId: null);
      }

      if (context.mounted) {
        context.go(AppRoutes.home);
      }
    } catch (e) {
      SnackbarService.showError(AppErrorParser.parse(e));
      if (context.mounted) {
        context.go(AppRoutes.login);
      }
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
      SnackbarService.showError(AppErrorParser.parse(e));
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
