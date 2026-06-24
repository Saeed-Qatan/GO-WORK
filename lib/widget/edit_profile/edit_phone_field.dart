import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../viewmodel/edit_profile_view_model.dart';

class EditPhoneField extends StatelessWidget {
  final EditProfileViewModel viewModel;

  const EditPhoneField({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
<<<<<<< HEAD
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
=======
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, right: 4.5),
>>>>>>> e-all
          child: Text(
            AppConstants.phoneLabel,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.textPrimary.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Directionality(
<<<<<<< HEAD
          textDirection: TextDirection.ltr,
=======
          textDirection: TextDirection.rtl,
>>>>>>> e-all
          child: TextFormField(
            controller: viewModel.phoneController,
            validator: (val) => viewModel.formData.validatePhone(val ?? ''),
            keyboardType: TextInputType.phone,
<<<<<<< HEAD
            textAlign: TextAlign.left,
=======
            textAlign: TextAlign.right,
>>>>>>> e-all
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              errorStyle: const TextStyle(fontWeight: FontWeight.w500),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
