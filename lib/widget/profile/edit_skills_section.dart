import 'package:flutter/material.dart';
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
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text(AppConstants.cancel),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            viewModel.addSkill();
                            Navigator.pop(ctx);
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
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              AppConstants.skills,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
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
              backgroundColor: AppColors.primary.withOpacity(0.1),
              side: BorderSide(color: AppColors.primary.withOpacity(0.2)),
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
