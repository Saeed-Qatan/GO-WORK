import 'package:flutter/material.dart';

import 'package:gowork/core/constants/app_constants.dart';
import 'package:gowork/theme/app_colors.dart';
import 'package:gowork/view/auth/forget_page.dart';
import 'package:gowork/view/auth/register_info_page.dart';
import 'package:gowork/view/main_view.dart';
import 'package:gowork/viewmodel/auth/login_view_model.dart';
import 'package:gowork/widget/custom_button.dart';
import 'package:gowork/widget/custom_text_field.dart';
import 'package:gowork/widget/social_button.dart';
import 'package:gowork/utils/navigations.dart';
import 'package:provider/provider.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Consumer<LoginViewModel>(
            builder: (context, viewModel, child) {
              return Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    // Icon placeholder
                    Container(
                      height: 90,
                      width: 90,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.5),
                            blurRadius: 5,
                            spreadRadius: 1,
                            offset: const Offset(0, 7),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        color: Colors.white,
                        size: 45,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      AppConstants.welcomeBack,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppConstants.loginSubtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 48),
                    CustomTextField(
                      label: AppConstants.emailLabel,
                      hint: AppConstants.emailHint,
                      prefixIcon: Icons.email_outlined,
                      controller: _emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال البريد الإلكتروني';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    CustomTextField(
                      label: AppConstants.passwordLabel,
                      hint: AppConstants.passwordHint,
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      controller: _passwordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال كلمة المرور';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: viewModel.rememberMe,
                              activeColor: const Color(0xff1F59DF),
                              onChanged: viewModel.toggleRememberMe,
                              side: const BorderSide(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const Text(
                              AppConstants.rememberMe,
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            NavigationService.navigateTo(const ForgetPage());
                          },
                          child: Text(
                            AppConstants.forgotPassword,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (viewModel.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          viewModel.errorMessage!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.error),
                        ),
                      ),
                    CustomButton(
                      text: AppConstants.loginButton,
                      isLoading: viewModel.isLoading,
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final success = await viewModel.login(
                            _emailController.text,
                            _passwordController.text,
                          );
                          if (success) {
                            if (context.mounted) {
                              NavigationService.pushReplacement(
                                const MainView(),
                              );
                            }
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            AppConstants.orSeparator,
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                      ],
                    ),
                    const SizedBox(height: 32),
                    SocialButton(
                      text: AppConstants.googleLogin,
                      onPressed: () {},
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          AppConstants.noAccount,
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        TextButton(
                          onPressed: () {
                            NavigationService.navigateTo(const RegisterPage());
                          },
                          child: Text(
                            AppConstants.createAccount,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
