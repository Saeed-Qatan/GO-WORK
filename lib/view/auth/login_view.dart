import 'dart:async';

import 'package:flutter/material.dart';

import 'package:gowork/core/constants/app_constants.dart';
import 'package:gowork/viewmodel/auth/login_view_model.dart';
import 'package:gowork/viewmodel/home_view_model.dart';
import 'package:gowork/viewmodel/profile_view_model.dart';
import 'package:gowork/widget/custom_button.dart';
import 'package:gowork/widget/custom_text_field.dart';
import 'package:go_router/go_router.dart';
import 'package:gowork/routing/app_router.dart';
import 'package:provider/provider.dart';
import 'package:gowork/utils/snackbar_service.dart';
import 'package:gowork/utils/session_state_reset.dart';

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
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                        color: cs.primary,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).shadowColor.withValues(alpha: 0.5),
                            blurRadius: 5,
                            spreadRadius: 1,
                            offset: const Offset(0, 7),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.person_outline,
                        color: cs.onPrimary,
                        size: 45,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      AppConstants.welcomeBack,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppConstants.loginSubtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
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
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        TextButton(
                          onPressed: () {
                            context.push(AppRoutes.forgetPassword);
                          },
                          child: Text(
                            AppConstants.forgotPassword,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: cs.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
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
                              SnackbarService.showSuccess(
                                'تم تسجيل الدخول بنجاح',
                              );
                              final profileSnapshot = viewModel.profileSnapshot;
                              resetSessionState(context);
                              if (profileSnapshot != null) {
                                context.read<ProfileViewModel>().seedProfile(
                                  profileSnapshot,
                                  notify: false,
                                );
                                context
                                    .read<HomeViewModel>()
                                    .seedProfileSummary(
                                      profileSnapshot,
                                      notify: false,
                                    );
                              } else {
                                unawaited(
                                  context
                                      .read<ProfileViewModel>()
                                      .fetchProfile(),
                                );
                              }
                              context.go(AppRoutes.home);
                            }
                          } else {
                            if (context.mounted) {
                              SnackbarService.showError(
                                viewModel.errorMessage ?? 'فشل تسجيل الدخول',
                              );
                            }
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: Divider(color: Theme.of(context).dividerColor),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            AppConstants.orSeparator,
                            style: TextStyle(color: cs.onSurfaceVariant),
                          ),
                        ),
                        Expanded(
                          child: Divider(color: Theme.of(context).dividerColor),
                        ),
                      ],
                    ),
                    // google button
                    // TODO: implement google login
                    // const SizedBox(height: 32),
                    // SocialButton(
                    //   text: AppConstants.googleLogin,
                    //   onPressed: () {},
                    // ),
                    // const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppConstants.noAccount,
                          style: TextStyle(color: cs.onSurfaceVariant),
                        ),
                        TextButton(
                          onPressed: () {
                            context.push(AppRoutes.registerInfo);
                          },
                          child: Text(
                            AppConstants.createAccount,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: cs.primary,
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
