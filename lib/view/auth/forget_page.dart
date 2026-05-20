// lib/view/auth/forget_page.dart
import 'package:flutter/material.dart';
import 'package:gowork/core/constants/app_constants.dart';
import 'package:gowork/theme/app_colors.dart';
import 'package:gowork/theme/app_theme.dart';
import 'package:gowork/widget/custom_button.dart';
import 'package:gowork/widget/display_box_widget.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:gowork/routing/app_router.dart';

import 'package:gowork/viewmodel/auth/forget_view_model.dart';

class ForgetPage extends StatelessWidget {
  const ForgetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ForgetViewModel(),
      child: Consumer<ForgetViewModel>(
        builder: (context, vm, child) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: IconThemeData(
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
            ),
            body: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: DisplayBoxWidget(
                  icon: Icons.lock_reset_rounded,
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        AppConstants.forgotPassword,
                        style: Theme.of(
                          context,
                        ).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "أدخل بريدك الإلكتروني لاستعادة كلمة المرور",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextField(
                        controller: vm.emailController,
                        decoration: InputDecoration(
                          hintText: AppConstants.emailHint,
                          labelText: AppConstants.emailLabel,
                          suffixIcon: const Icon(Icons.email_outlined),
                          filled: true,
                          fillColor: AppColors.inputBackground,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      if (vm.error != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          vm.error!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.error),
                        ),
                      ],
                      const SizedBox(height: 20),
                      CustomButton(
                        text: vm.isLoading ? 'جارٍ...' : 'إرسال رابط الاستعادة',
                        icon: const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                        ),
                        color:
                            vm.canSubmit
                                ? AppColors.primary
                                : AppColors.textHint,
                        textColor: Colors.white,
                        onPressed:
                            vm.canSubmit
                                ? () {
                                  FocusScope.of(context).unfocus();
                                  vm.submit(context);
                                }
                                : null,
                      ),
                      const SizedBox(height: 15),
                      TextButton(
                        onPressed: () {
                          context.go(AppRoutes.login);
                        },
                        child: Text(
                          "العودة لتسجيل الدخول",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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
