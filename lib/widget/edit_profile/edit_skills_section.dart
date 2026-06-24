import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../viewmodel/edit_profile_view_model.dart';

class EditSkillsSection extends StatelessWidget {
  final EditProfileViewModel viewModel;

  const EditSkillsSection({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with "add" link
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 4.5),
              child: Text(
                AppConstants.skills,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) {
                    return AlertDialog(
                      title: const Text('إضافة مهارة'),
                      content: TextField(
                        controller: viewModel.skillController,
                        autofocus: true,
                        decoration: const InputDecoration(
                          hintText: AppConstants.addSkillHint,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => ctx.pop(),
                          child: const Text(AppConstants.cancel),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            viewModel.addSkill();
                            ctx.pop();
                          },
                          child: const Text(AppConstants.addSkill),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text(
                AppConstants.addSkill,
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Skill chips with delete
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.start,
          children: List.generate(viewModel.formData.skills.length, (index) {
            return Chip(
              label: Text(
                viewModel.formData.skills[index],
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              deleteIcon: const Icon(
                Icons.close,
                size: 16,
                color: AppColors.primary,
              ),
              onDeleted: () => viewModel.removeSkill(index),
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            );
          }),
        ),
      ],
    );
  }
}
