import 'package:flutter/material.dart';
import 'package:gowork/model/auth/register_data_model.dart';
import 'package:gowork/utils/navigations.dart';

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
    return null;
  }

  String? validateEmail(String? v) {
    if (v == null || v.isEmpty) return 'الرجاء إدخال البريد الإلكتروني';
    if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
      return 'البريد الإلكتروني غير صالح';
    }
    return null;
  }

  String? validatePhone(String? v) {
    if (v == null || v.trim().isEmpty) return 'الرجاء إدخال رقم الهاتف';
    if (!RegExp(r'^[0-9]+$').hasMatch(v)) {
      return 'رقم الهاتف يجب أن يحتوي على أرقام فقط';
    }
    if (v.length < 8) return 'رقم الهاتف قصير جداً';
    return null;
  }

  String? validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'الرجاء إدخال كلمة المرور';
    if (v.length < 6) return 'كلمة المرور قصيرة جداً';

    // Check for English characters and complexity
    bool hasUppercase = v.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = v.contains(RegExp(r'[a-z]'));
    bool hasDigits = v.contains(RegExp(r'[0-9]'));

    if (!hasUppercase) return 'يجب أن تحتوي على حرف كبير واحد على الأقل';
    if (!hasLowercase) return 'يجب أن تحتوي على حرف صغير واحد على الأقل';
    if (!hasDigits) return 'يجب أن تحتوي على رقم واحد على الأقل';

    return null;
  }

  String? validateConfirmPassword(String? v) {
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

    Navigator.pushNamed(context, Routes.registerPhoto, arguments: data);
  }

  void onLoginPressed(BuildContext context) {
    Navigator.pushReplacementNamed(context, Routes.login);
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
