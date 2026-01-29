import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../theme/app_colors.dart';

class HomeFilters extends StatelessWidget {
  const HomeFilters({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.inputBorder),
            ),
            child: Row(
              children: [
                Text(
                  AppConstants.allFields,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
          Text(
            AppConstants.recommendedJobs,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
