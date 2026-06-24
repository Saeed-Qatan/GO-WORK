import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../core/constants/app_constants.dart';

class ProfileContactInfoCard extends StatelessWidget {
  final String email;
  final String phone;

  const ProfileContactInfoCard({
    super.key,
    required this.email,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Section header
          Row(
<<<<<<< HEAD
            mainAxisAlignment: MainAxisAlignment.end,
=======
            mainAxisAlignment: MainAxisAlignment.start,
>>>>>>> e-all
            children: [
              Text(
                AppConstants.contactInfo,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.contact_page_outlined,
                color: AppColors.primary,
                size: 22,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Email row
          _ContactRow(
            icon: Icons.email_outlined,
            label: AppConstants.emailTitle,
            value: email,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: Color(0xFFEEEEEE)),
          ),

          // Phone row
          _ContactRow(
            icon: Icons.phone_outlined,
            label: AppConstants.phoneTitle,
            value: phone,
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Text content
        Expanded(
          child: Column(
<<<<<<< HEAD
            crossAxisAlignment: CrossAxisAlignment.end,
=======
            crossAxisAlignment: CrossAxisAlignment.start,
>>>>>>> e-all
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    value,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
<<<<<<< HEAD

=======
>>>>>>> e-all
        // Icon container
        Container(
          width: 40,
          height: 40,
<<<<<<< HEAD
=======

>>>>>>> e-all
          decoration: BoxDecoration(
            color: const Color(0xFFE8F0FE),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
      ],
    );
  }
}
