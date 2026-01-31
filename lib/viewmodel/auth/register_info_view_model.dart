import 'package:flutter/material.dart';
import 'package:gowork/model/auth/register_data_model.dart';
import 'package:gowork/utils/navigations.dart';

class RegisterInfoViewModel extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController fatherNameController = TextEditingController();
  final TextEditingController familyNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool isLoading = false;
  String? errorMessage;

  void togglePassword() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  void toggleConfirmPassword() {
    obscureConfirmPassword = !obscureConfirmPassword;
    notifyListeners();
  }

  String? validateNotEmpty(String? val, String field) {
    if (val == null || val.isEmpty) return 'الرجاء إدخال $field';
    return null;
  }

  String? validateEmail(String? val) {
    if (val == null || val.isEmpty) return 'الرجاء إدخال البريد الإلكتروني';
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(val)) return 'البريد الإلكتروني غير صالح';
    return null;
  }

  String? validatePassword(String? val) {
    if (val == null || val.isEmpty) return 'الرجاء إدخال كلمة المرور';
    if (val.length < 6) return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    return null;
  }

  String? validateConfirmPassword(String? val) {
    if (val == null || val.isEmpty) return 'الرجاء تأكيد كلمة المرور';
    if (val != passwordController.text) return 'كلمات المرور غير متطابقة';
    return null;
  }

  Future<void> onContinuePressed(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final data = RegisterDataModel(
        firstName: firstNameController.text,
        fatherName: fatherNameController.text,
        familyName: familyNameController.text,
        email: emailController.text,
        phone: phoneController.text,
        password: passwordController.text,
        confirmPassword: confirmPasswordController.text,
      );

      if (context.mounted) {
        Navigator.pushNamed(context, Routes.registerPhoto, arguments: data);
      }
    } catch (e) {
      errorMessage = 'حدث خطأ، الرجاء المحاولة مرة أخرى';
    } finally {
      isLoading = false;
      notifyListeners();
    }
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
