import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../core/constants/app_constants.dart';

class ProfileActionButtons extends StatelessWidget {
  final VoidCallback onEditProfile;
  final VoidCallback onDownloadCV;

  const ProfileActionButtons({
    super.key,
    required this.onEditProfile,
    required this.onDownloadCV,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Download CV – outlined button
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onDownloadCV,
            icon: const Icon(
              Icons.download_rounded,
              size: 20,
              color: AppColors.primary,
            ),
            label: Text(
              AppConstants.downloadCV,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: AppColors.primary, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Edit Profile – filled button
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onEditProfile,
            icon: const Icon(Icons.edit, size: 18, color: Colors.white),
            label: Text(
              AppConstants.editProfileBtn,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
