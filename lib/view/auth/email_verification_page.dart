import 'package:flutter/material.dart';
import 'package:gowork/theme/app_colors.dart';
import 'package:gowork/viewmodel/auth/email_verification_view_model.dart';
import 'package:gowork/widget/custom_button.dart';
import 'package:provider/provider.dart';

class EmailVerificationPage extends StatelessWidget {
  const EmailVerificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final email = ModalRoute.of(context)?.settings.arguments as String?;

    return ChangeNotifierProvider(
      create: (_) {
        final viewModel = EmailVerificationViewModel();
        if (email != null) {
          viewModel.setArgs(email);
        }
        return viewModel;
      },
      child: Consumer<EmailVerificationViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
                  constraints: const BoxConstraints(maxWidth: 500),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 20),
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
                          Icons.mark_email_read_outlined,
                          size: 45,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "تأكيد البريد الإلكتروني",
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "تم إرسال رمز التحقق إلى بريدك الإلكتروني\n${viewModel.email ?? ''}",
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(6, (index) {
                            return SizedBox(
                              width: 40,
                              height: 50,
                              child: TextField(
                                controller: viewModel.controllers[index],
                                focusNode: viewModel.focusNodes[index],
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                maxLength: 1,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: InputDecoration(
                                  counterText: "",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: AppColors.primary,
                                      width: 2,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onChanged: (value) =>
                                    viewModel.onCodeChanged(value, index),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 30),
                      viewModel.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : CustomButton(
                              text: 'تأكيد',
                              color: AppColors.primary,
                              textColor: Colors.white,
                              onPressed: () => viewModel.verify(context),
                            ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "لم يصلك الرمز؟",
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          TextButton(
                            onPressed: viewModel.countdown > 0
                                ? null
                                : () => viewModel.resend(context),
                            child: Text(
                              viewModel.countdown > 0
                                  ? "  ${viewModel.countdown} ثانية"
                                  : "إعادة إرسال",
                              style: TextStyle(
                                color: viewModel.countdown > 0
                                    ? Colors.grey
                                    : AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
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
