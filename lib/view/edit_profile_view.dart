import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../viewmodel/edit_profile_view_model.dart';
import '../viewmodel/profile_view_model.dart';
import '../theme/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../widget/edit_profile/edit_avatar_section.dart';
import '../widget/edit_profile/edit_labeled_field.dart';
import '../widget/edit_profile/edit_phone_field.dart';
import '../widget/edit_profile/edit_skills_section.dart';
import '../widget/edit_profile/edit_cv_section.dart';
import '../widget/search/filter_dropdown.dart';
import '../model/search/filter_option.dart';

class EditProfileView extends StatelessWidget {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => EditProfileViewModel(
        Provider.of<ProfileViewModel>(context, listen: false),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FB),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF5F7FB),
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(
            AppConstants.editProfileTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
          leading: TextButton(
            onPressed: () => context.pop(),
            child: Text(
              AppConstants.cancel,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.arrow_forward, color: AppColors.primary),
              onPressed: () => context.pop(),
            ),
          ],
        ),
        body: Consumer<EditProfileViewModel>(
          builder: (context, viewModel, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Form(
                key: viewModel.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Avatar Section ──
                    EditAvatarSection(viewModel: viewModel),
                    const SizedBox(height: 28),

                    // ── First Name ──
                    EditLabeledField(
                      label: AppConstants.firstNameLabel,
                      controller: viewModel.firstNameController,
                      validator: (val) => viewModel.formData.validateName(
                        val ?? '',
                        AppConstants.firstNameLabel,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Middle Name + Last Name side by side ──
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: EditLabeledField(
                            label: AppConstants.lastNameLabel,
                            controller: viewModel.lastNameController,
                            validator: (val) => viewModel.formData.validateName(
                              val ?? '',
                              AppConstants.lastNameLabel,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: EditLabeledField(
                            label: AppConstants.middleNameLabel,
                            controller: viewModel.middleNameController,
                            // Middle name is optional usually, but we can validate length if not empty
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Phone Number ──
                    EditPhoneField(viewModel: viewModel),
                    const SizedBox(height: 24),

                    if (viewModel.isCategoriesLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (viewModel.categories.isNotEmpty)
                      FilterDropdown(
                        label: 'المجال المناسب',
                        hint: 'لم يتم الاختيار',
                        value: viewModel.selectedCategoryId != null
                            ? FilterOption(
                                label:
                                    viewModel.categories
                                        .firstWhere(
                                          (cat) =>
                                              cat['id'].toString() ==
                                              viewModel.selectedCategoryId,
                                          orElse: () => <String, dynamic>{
                                            'name': '',
                                          },
                                        )['name']
                                        ?.toString() ??
                                    '',
                                rawValue: viewModel.selectedCategoryId!,
                              )
                            : null,
                        items: viewModel.categories
                            .map(
                              (cat) => FilterOption(
                                label: cat['name'].toString(),
                                rawValue: cat['id'].toString(),
                              ),
                            )
                            .toList(),
                        onChanged: (FilterOption? newFieldValue) {
                          viewModel.setCategory(newFieldValue?.rawValue);
                        },
                      )
                    else
                      Column(
                        children: [
                          Text(
                            viewModel.categoriesErrorMessage ??
                                'تعذر تحميل المجالات. يرجى المحاولة مرة أخرى.',
                            style: const TextStyle(
                              color: AppColors.error,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: viewModel.fetchCategories,
                            icon: const Icon(Icons.refresh),
                            label: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    const SizedBox(height: 24),

                    // ── Skills ──
                    EditSkillsSection(viewModel: viewModel),
                    const SizedBox(height: 24),

                    // ── CV Upload ──
                    EditCVSection(viewModel: viewModel),
                    const SizedBox(height: 32),

                    // ── Save Button ──
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: viewModel.isLoading
                            ? null
                            : () async {
                                final success = await viewModel.saveProfile();
                                if (success && context.mounted) {
                                  context.pop();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          disabledBackgroundColor: AppColors.primary.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        child: viewModel.isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                AppConstants.saveChanges,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
