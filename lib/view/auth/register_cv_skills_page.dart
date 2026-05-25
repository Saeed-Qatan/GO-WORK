import 'package:flutter/material.dart';
import 'package:gowork/theme/app_colors.dart';
import 'package:gowork/viewmodel/auth/register_cv_view_model.dart';
import 'package:gowork/widget/custom_button.dart';
import 'package:provider/provider.dart';
import 'package:gowork/widget/search/filter_dropdown.dart';
import 'package:gowork/model/auth/register_data_model.dart';
import 'package:gowork/model/search/filter_option.dart';
import 'package:go_router/go_router.dart';

class RegisterCVPage extends StatefulWidget {
  final RegisterDataModel data;
  const RegisterCVPage({super.key, required this.data});

  @override
  State<RegisterCVPage> createState() => _RegisterCVPageState();
}

class _RegisterCVPageState extends State<RegisterCVPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterCVViewModel(),
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
            child: Consumer<RegisterCVViewModel>(
              builder: (context, viewModel, child) {
                // CV is optional — backend accepts registration without it.
                // Required: at least one skill + a category (when categories loaded).
                final isFormComplete =
                    viewModel.skills.isNotEmpty &&
                    viewModel.categories.isNotEmpty &&
                    viewModel.selectedCategoryId != null &&
                    !viewModel.isCategoriesLoading;

                final availableSuggestedSkills = viewModel.suggestedSkills
                    .where((skill) => !viewModel.skills.contains(skill))
                    .toList();

                return Container(
                  padding: const EdgeInsets.all(15),
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 40),
                      Container(
                        height: 90,
                        width: 90,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
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
                          Icons.file_present_rounded,
                          size: 45,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "السيرة الذاتية والمهارات",
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "أكمل ملفك الشخصي لتحصل على أفضل الفرص",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 25),

                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "رفع السيرة الذاتية",
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () => viewModel.pickCV(),
                        child: Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.border,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(15),
                            color: AppColors.inputBackground,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.upload_file_outlined,
                                size: 40,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(height: 10),
                              if (viewModel.cvFileName != null &&
                                  viewModel.cvFileName!.isNotEmpty)
                                Consumer<RegisterCVViewModel>(
                                  builder: (context, cvViewModel, child) =>
                                      Text(
                                        cvViewModel.cvFileName!,
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                )
                              else
                                ElevatedButton(
                                  onPressed: () => viewModel.pickCV(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xffF6F9FF),
                                    foregroundColor: Theme.of(
                                      context,
                                    ).primaryColor,
                                    elevation: 0,
                                  ),
                                  child: const Text("اختر ملف السيرة الذاتية"),
                                ),
                              const SizedBox(height: 8),
                              const Text(
                                "(الحد الأقصى 10MB - PDF, DOC, DOCX)",
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),

                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "المهارات",
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.add, color: Colors.white),
                              onPressed: () => viewModel.addSkill(),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: viewModel.skillController,
                              style: Theme.of(context).textTheme.bodyMedium,
                              decoration: InputDecoration(
                                hintText: "أضف مهارة جديدة...",
                                filled: true,
                                fillColor: AppColors.inputBackground,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                              ),
                              onSubmitted: (value) => viewModel.addSkill(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          alignment: WrapAlignment.start,
                          children: viewModel.skills
                              .map(
                                (skill) => Chip(
                                  label: Text(skill),
                                  deleteIcon: const Icon(Icons.close, size: 16),
                                  onDeleted: () => viewModel.removeSkill(skill),
                                  backgroundColor: AppColors.inputBackground,
                                  side: BorderSide.none,
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "مهارات مقترحة:",
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          alignment: WrapAlignment.start,
                          children: availableSuggestedSkills
                              .map(
                                (skill) => ActionChip(
                                  label: Text(skill),
                                  backgroundColor: AppColors.inputBackground,
                                  labelStyle: TextStyle(
                                    color: AppColors.textPrimary,
                                  ),
                                  side: BorderSide.none,
                                  onPressed: () =>
                                      viewModel.addSuggestedSkill(skill),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 25),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "المجال المناسب",
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (viewModel.isCategoriesLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (viewModel.categories.isNotEmpty)
                        FilterDropdown(
                          label: 'اختر مجالك المهني',
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
                      const SizedBox(height: 35),
                      Consumer<RegisterCVViewModel>(
                        builder: (context, cvViewModel, child) {
                          return cvViewModel.isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : CustomButton(
                                  icon: const Icon(
                                    Icons.check_circle_outline,
                                    color: Colors.white,
                                  ),
                                  text: 'إنهاء التسجيل',
                                  color: isFormComplete
                                      ? Theme.of(context).primaryColor
                                      : AppColors.textHint,
                                  textColor: Colors.white,
                                  onPressed: isFormComplete
                                      ? () => cvViewModel.finishRegistration(
                                          context,
                                          widget.data,
                                        )
                                      : null,
                                );
                        },
                      ),

                      const SizedBox(height: 15),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.border,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.border,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
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
