import 'package:flutter/material.dart';
import 'package:gowork/model/auth/register_data_model.dart';
import 'package:gowork/view/auth/register_cv_skills_page.dart';
import 'package:gowork/view/auth/login_view.dart';
import 'package:provider/provider.dart';

class RegisterInfoViewModel extends ChangeNotifier {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController fatherNameController = TextEditingController();
  final TextEditingController familyNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool get obscurePassword => _obscurePassword;

  bool _obscureConfirmPassword = true;
  bool get obscureConfirmPassword => _obscureConfirmPassword;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    notifyListeners();
  }

  String? notEmptyValidator(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال $fieldName';
    }
    return null;
  }

  String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال البريد الإلكتروني';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'البريد الإلكتروني غير صالح';
    }
    return null;
  }

  String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال كلمة المرور';
    }
    if (value.length < 6) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }
    return null;
  }

  String? confirmPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء تأكيد كلمة المرور';
    }
    if (value != passwordController.text) {
      return 'كلمات المرور غير متطابقة';
    }
    return null;
  }

  Future<void> onContinuePressed(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Update the data model
      final dataModel = Provider.of<RegisterDataModel>(context, listen: false);
      dataModel.firstName = firstNameController.text;
      dataModel.fatherName = fatherNameController.text;
      dataModel.familyName = familyNameController.text;
      dataModel.email = emailController.text;
      dataModel.phone = phoneController.text;
      dataModel.password = passwordController.text;

      // Navigate to next page
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RegisterCVPage()),
        );
      }
    } catch (e) {
      _errorMessage = 'حدث خطأ، الرجاء المحاولة مرة أخرى';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void onLoginPressed(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginView()),
    );
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
