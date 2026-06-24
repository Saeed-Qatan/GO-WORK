// ignore_for_file: non_constant_identifier_names

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gowork/theme/app_colors.dart';

import 'package:gowork/viewmodel/auth/register_info_view_model.dart';
import 'package:gowork/widget/custom_button.dart';
import 'package:gowork/widget/custom_text_field.dart';
import 'package:provider/provider.dart';
import 'package:gowork/widget/common/password_rules_widget.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterInfoViewModel(),
      child: Consumer<RegisterInfoViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: AppColors.background,
<<<<<<< HEAD
            body: Center(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.textSecondary.withValues(alpha: 0.1),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Form(
                    key: viewModel.formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 10),
                        Container(
                          height: 90,
                          width: 90,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.5,
                                ),
                                blurRadius: 5,
                                spreadRadius: 1,
                                offset: const Offset(0, 7),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person_add_alt_1,
                            size: 45,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "إنشاء حساب جديد",
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          controller: viewModel.firstNameController,
                          label: 'اسم الاول',
                          hint: 'الاسم الاول',
                          validator: (val) =>
                              viewModel.validateNotEmpty(val, 'الاسم الاول'),
                        ),
                        const SizedBox(height: 10),
                        CustomTextField(
                          controller: viewModel.fatherNameController,
                          label: 'اسم الاب',
                          hint: 'الاسم الثاني',
                          validator: (val) =>
                              viewModel.validateNotEmpty(val, 'اسم الاب'),
                        ),
                        const SizedBox(height: 10),
                        CustomTextField(
                          controller: viewModel.familyNameController,
                          label: 'اسم العائلة',
                          hint: 'اللقب',
                          validator: (val) =>
                              viewModel.validateNotEmpty(val, 'اسم العائلة'),
                        ),
                        const SizedBox(height: 10),
                        CustomTextField(
                          controller: viewModel.emailController,
                          label: 'البريد الإلكتروني',
                          hint: 'yourmail@gmail.com',
                          validator: viewModel.validateEmail,
                        ),
                        const SizedBox(height: 10),
                        CustomTextField(
                          controller: viewModel.phoneController,
                          label: 'رقم الهاتف',
                          hint: 'رقم الهاتف',
                          validator: viewModel.validatePhone,
                        ),
                        const SizedBox(height: 10),
                        CustomTextField(
                          label: 'كلمة المرور',
                          controller: viewModel.passwordController,
                          hint: 'كلمة المرور',
                          isPassword: true,
                          validator: viewModel.validatePassword,
                        ),
                        PasswordRulesWidget(
                          controller: viewModel.passwordController,
                        ),
                        const SizedBox(height: 10),
                        CustomTextField(
                          controller: viewModel.confirmPasswordController,
                          hint: 'تأكيد كلمة المرور',
                          label: 'تأكيد كلمة المرور',
                          isPassword: true,
                          validator: viewModel.validateConfirmPassword,
                        ),
                        if (viewModel.errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Text(
                              viewModel.errorMessage!,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.error),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        const SizedBox(height: 20),
                        viewModel.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : CustomButton(
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                ),
                                text: 'متابعة',
                                color: AppColors.primary,
                                textColor: Colors.white,
                                onPressed: () {
                                  viewModel.onContinuePressed(context);
                                },
                              ),
                        const SizedBox(height: 15),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'لديك حساب بالفعل؟ ',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const TextSpan(text: "  "),
                              TextSpan(
                                text: "تسجيل الدخول",
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    viewModel.onLoginPressed(context);
                                  },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text(
                            "بالتسجيل، أنت توافق على سياسة الخصوصية والشروط والأحكام",
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
=======
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    width: MediaQuery.of(context).size.width * 0.9,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.textSecondary.withValues(alpha: 0.1),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Form(
                      key: viewModel.formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 10),
                          Container(
                            height: 90,
                            width: 90,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.textSecondary.withValues(
                                    alpha: 0.5,
                                  ),
                                  blurRadius: 5,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 7),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.person_add_alt_1,
                              size: 45,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "إنشاء حساب جديد",
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            controller: viewModel.firstNameController,
                            label: 'اسم الاول',
                            hint: 'الاسم الاول',
                            validator: (val) =>
                                viewModel.validateNotEmpty(val, 'الاسم الاول'),
                          ),
                          const SizedBox(height: 10),
                          CustomTextField(
                            controller: viewModel.fatherNameController,
                            label: 'اسم الاب',
                            hint: 'الاسم الثاني',
                            validator: (val) =>
                                viewModel.validateNotEmpty(val, 'اسم الاب'),
                          ),
                          const SizedBox(height: 10),
                          CustomTextField(
                            controller: viewModel.familyNameController,
                            label: 'اسم العائلة',
                            hint: 'اللقب',
                            validator: (val) =>
                                viewModel.validateNotEmpty(val, 'اسم العائلة'),
                          ),
                          const SizedBox(height: 10),
                          CustomTextField(
                            controller: viewModel.emailController,
                            label: 'البريد الإلكتروني',
                            hint: 'yourmail@gmail.com',
                            validator: viewModel.validateEmail,
                          ),
                          const SizedBox(height: 10),
                          CustomTextField(
                            controller: viewModel.phoneController,
                            label: 'رقم الهاتف',
                            hint: 'رقم الهاتف',
                            validator: viewModel.validatePhone,
                          ),
                          const SizedBox(height: 10),
                          CustomTextField(
                            label: 'كلمة المرور',
                            controller: viewModel.passwordController,
                            hint: 'كلمة المرور',
                            isPassword: true,
                            validator: viewModel.validatePassword,
                          ),
                          PasswordRulesWidget(
                            controller: viewModel.passwordController,
                          ),
                          const SizedBox(height: 10),
                          CustomTextField(
                            controller: viewModel.confirmPasswordController,
                            hint: 'تأكيد كلمة المرور',
                            label: 'تأكيد كلمة المرور',
                            isPassword: true,
                            validator: viewModel.validateConfirmPassword,
                          ),
                          if (viewModel.errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Text(
                                viewModel.errorMessage!,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.error),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          const SizedBox(height: 20),
                          viewModel.isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : CustomButton(
                                  icon: const Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                  ),
                                  text: 'متابعة',
                                  color: AppColors.primary,
                                  textColor: Colors.white,
                                  onPressed: () {
                                    viewModel.onContinuePressed(context);
                                  },
                                ),
                          const SizedBox(height: 15),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'لديك حساب بالفعل؟ ',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const TextSpan(text: "  "),
                                TextSpan(
                                  text: "تسجيل الدخول",
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      viewModel.onLoginPressed(context);
                                    },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 15),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                            ),
                            child: Text(
                              "بالتسجيل، أنت توافق على سياسة الخصوصية والشروط والأحكام",
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
>>>>>>> e-all
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
