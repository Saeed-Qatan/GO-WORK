import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData? prefixIcon;
  final bool isPassword;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    this.prefixIcon,
    this.isPassword = false,
    required this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
            suffixIcon: isPassword
                ? const Icon(
                    Icons.visibility_off_outlined,
                    color: AppColors.textSecondary,
                  ) // Simplified for UI, logic can be added later
                : null,
          ),
        ),
      ],
    );
  }
}
