import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gowork/theme/app_colors.dart';
import 'package:gowork/viewmodel/auth/reset_password_view_model.dart';
import 'package:gowork/widget/custom_button.dart';
import 'package:gowork/widget/custom_text_field.dart';
import 'package:gowork/widget/display_box_widget.dart';
import 'package:go_router/go_router.dart';

class ResetPasswordView extends StatelessWidget {
  final String email;

  const ResetPasswordView({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ResetPasswordViewModel(email: email),
      child: Consumer<ResetPasswordViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: AppColors.textPrimary),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
            ),
            body: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: DisplayBoxWidget(
                  icon: Icons.lock_reset,
                  child: Form(
                    key: viewModel.formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.lock_reset,
                            size: 40,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'إعادة تعيين كلمة المرور',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'أدخل الكود المرسل إلى بريدك الإلكتروني وكلمة المرور الجديدة',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 32),
                        CustomTextField(
                          label: 'كود التحقق',
                          hint: 'أدخل الكود',
                          prefixIcon: Icons.vpn_key_outlined,
                          controller: viewModel.codeController,
                          validator: viewModel.validateCode,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: 'كلمة المرور الجديدة',
                          hint: '********',
                          prefixIcon: Icons.lock_outline,
                          isPassword: true,
                          controller: viewModel.passwordController,
                          validator: viewModel.validatePassword,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: 'تأكيد كلمة المرور',
                          hint: '********',
                          prefixIcon: Icons.lock_outline,
                          isPassword: true,
                          controller: viewModel.confirmPasswordController,
                          validator: viewModel.validateConfirmPassword,
                        ),
                        const SizedBox(height: 24),
                        if (viewModel.errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Text(
                              viewModel.errorMessage!,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.error),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        CustomButton(
                          text: 'تغيير كلمة المرور',
                          isLoading: viewModel.isLoading,
                          onPressed: () {
                            viewModel.submit(context);
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
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
