// ignore_for_file: non_constant_identifier_names

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:gowork/viewmodel/auth/register_info_view_model.dart';
import 'package:gowork/widget/custom_button.dart';
import 'package:gowork/widget/custom_text_field.dart';
import 'package:gowork/widget/display_box_widget.dart';
import 'package:provider/provider.dart';

class RegisterInfoPage1 extends StatefulWidget {
  const RegisterInfoPage1({super.key});

  @override
  State<RegisterInfoPage1> createState() => _RegisterInfoPage1State();
}

class _RegisterInfoPage1State extends State<RegisterInfoPage1> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterInfoViewModel(),
      child: Consumer<RegisterInfoViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: DisplayBoxWidget(
                  icon: Icons.person_add_alt_1,
                  child: Form(
                    key: viewModel.formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Text(
                          "إنشاء حساب جديد",
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                        ),
                        const SizedBox(height: 30),

                        // الاسم الأول
                        CustomTextField(
                          controller: viewModel.firstNameController,
                          hint: '  علي',
                          label: ' الاسم الاول',
                        ),
                        const SizedBox(height: 10),

                        // اسم الأب
                        CustomTextField(
                          controller: viewModel.fatherNameController,
                          hint: '   ناصر ',
                          label: ' اسم الأب',
                        ),
                        const SizedBox(height: 10),

                        // اسم العائلة
                        CustomTextField(
                          controller: viewModel.familyNameController,
                          hint: '   بامخشب  ',
                          label: ' اسم العائلة ',
                        ),
                        const SizedBox(height: 10),

                        // البريد الإلكتروني
                        CustomTextField(
                          controller: viewModel.emailController,
                          hint: 'ali@gmail.com',
                          label: 'البريد الإلكتروني',
                        ),
                        const SizedBox(height: 10),

                        // رقم الهاتف
                        CustomTextField(
                          controller: viewModel.phoneController,
                          hint: '+967774165326',
                          label: 'رقم الهاتف',
                        ),
                        const SizedBox(height: 10),

                        // كلمة المرور
                        CustomTextField(
                          label: 'كلمة المرور',
                          controller: viewModel.passwordController,
                          hint: 'كلمة المرور',
                          isPassword: true,
                        ),
                        const SizedBox(height: 10),

                        // تأكيد كلمة المرور
                        CustomTextField(
                          controller: viewModel.confirmPasswordController,
                          hint: 'تأكيد كلمة المرور',
                          label: 'تأكيد كلمة المرور',
                          isPassword: true,
                        ),

                        if (viewModel.errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Text(
                              viewModel.errorMessage!,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.red[700]),
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
                                color: Theme.of(context).primaryColor,
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
                                      color: Theme.of(context).primaryColor,
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

                        // Divider
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
