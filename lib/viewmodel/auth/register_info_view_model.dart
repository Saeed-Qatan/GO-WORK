import 'package:flutter/material.dart';
import 'package:gowork/model/auth/register_data_model.dart';
import 'package:go_router/go_router.dart';
import 'package:gowork/routing/app_router.dart';

class RegisterInfoViewModel extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final fatherNameController = TextEditingController();
  final familyNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;

  String? validateNotEmpty(String? v, String name) {
    if (v == null || v.trim().isEmpty) return 'الرجاء إدخال $name';
    if (v.trim().length < 2) return 'الاسم يجب أن يكون حرفين على الأقل';
    if (!RegExp(r'^[\p{L}\s]+$', unicode: true).hasMatch(v)) {
      return 'الاسم يجب أن يحتوي على أحرف فقط';
    }
    return null;
  }

  String? validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'الرجاء إدخال البريد الإلكتروني';
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    );
    if (!emailRegex.hasMatch(v.trim())) {
      return 'البريد الإلكتروني غير صالح';
    }
    return null;
  }

  String? validatePhone(String? v) {
    if (v == null || v.trim().isEmpty) return 'الرجاء إدخال رقم الهاتف';
    final phoneRegex = RegExp(r'^\+?[0-9]{8,15}$');
    if (!phoneRegex.hasMatch(v.trim())) {
      return 'رقم الهاتف غير صالح (8-15 رقم)';
    }
    return null;
  }

  String? validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'الرجاء إدخال كلمة المرور';
    if (v.length < 8) return 'يجب أن لا تقل كلمة المرور عن 8 أحرف';

    bool hasUppercase = v.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = v.contains(RegExp(r'[a-z]'));
    bool hasDigits = v.contains(RegExp(r'[0-9]'));
    bool hasSpecialCharacters = v.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    if (!hasUppercase) return 'يجب أن تحتوي على حرف إنجليزي كبير (A-Z)';
    if (!hasLowercase) return 'يجب أن تحتوي على حرف إنجليزي صغير (a-z)';
    if (!hasDigits) return 'يجب أن تحتوي على رقم واحد على الأقل (0-9)';
    if (!hasSpecialCharacters) return 'يجب أن تحتوي على رمز خاص (!@#\$&*)';

    return null;
  }

  String? validateConfirmPassword(String? v) {
    if (v == null || v.isEmpty) return 'الرجاء تأكيد كلمة المرور';
    if (v != passwordController.text) return 'كلمات المرور غير متطابقة';
    return null;
  }

  void onContinuePressed(BuildContext context) {
    if (!formKey.currentState!.validate()) return;

    final data = RegisterDataModel(
      firstName: firstNameController.text.trim(),
      fatherName: fatherNameController.text.trim(),
      familyName: familyNameController.text.trim(),
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
      password: passwordController.text,
      confirmPassword: confirmPasswordController.text,
    );

    context.push(AppRoutes.registerPhoto, extra: data);
  }

  void onLoginPressed(BuildContext context) {
    context.go(AppRoutes.login);
  }

  @override
  void dispose() {
    firstNameController.dispose();
    fatherNameController.dispose();
    familyNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
