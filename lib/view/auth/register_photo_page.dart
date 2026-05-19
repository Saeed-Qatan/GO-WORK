import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gowork/viewmodel/auth/register_upload_photo.dart';
import 'package:gowork/theme/app_colors.dart';
import 'package:gowork/widget/custom_button.dart';
import 'package:gowork/widget/display_box_widget.dart';
import 'package:gowork/model/auth/register_data_model.dart';
import 'package:go_router/go_router.dart';

class RegisterPhotoPage extends StatelessWidget {
  final RegisterDataModel data;
  const RegisterPhotoPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterPhotoViewModel(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Consumer<RegisterPhotoViewModel>(
              builder: (context, viewModel, child) {
                return DisplayBoxWidget(
                  icon: Icons.add_a_photo_outlined,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        "إضافة صورة شخصية",
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "الصورة الشخصية تساعد في تمييز ملفك",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      GestureDetector(
                        onTap: () => viewModel.pickFile(),
                        child: Container(
                          height: 180,
                          width: 180,
                          decoration: BoxDecoration(
                            color: AppColors.inputBackground,
                            borderRadius: BorderRadius.circular(90),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(90),
                            child: viewModel.selectedImage == null
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.camera_alt_outlined,
                                        size: 50,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "اختر صورة",
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  )
                                : Image.file(
                                    viewModel.selectedImage!,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      viewModel.isLoading
                          ? const CircularProgressIndicator()
                          : CustomButton(
                              text: 'متابعة',
                              onPressed: () =>
                                  viewModel.onContinuePressed(context, data),
                            ),
                      const SizedBox(height: 15),
                      TextButton(
                        onPressed: () => viewModel.onSkipPressed(context, data),
                        child: Text(
                          'تخطي الآن',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
