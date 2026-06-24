import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class EditLabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData? suffixIcon;
  final String? Function(String?)? validator;

  const EditLabeledField({
    super.key,
    required this.label,
    required this.controller,
    this.suffixIcon,
    this.validator,
  });

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
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.textPrimary.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
<<<<<<< HEAD
=======
          cursorColor: AppColors.primary,

>>>>>>> e-all
          textAlign: TextAlign.right,
          validator: validator,
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
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
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
            suffixIcon: suffixIcon != null ? Icon(suffixIcon, size: 20) : null,
          ),
        ),
      ],
    );
  }
}
