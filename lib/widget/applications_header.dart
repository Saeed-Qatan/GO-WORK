import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../viewmodel/applications_view_model.dart';

class ApplicationsHeader extends StatelessWidget {
  final ApplicationsViewModel viewModel;

  const ApplicationsHeader({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 40, bottom: 20, left: 16, right: 16),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  // Back navigation
                },
              ),
              Expanded(
                child: Text(
                  AppConstants.applicationsTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 48), // Balance the back button
            ],
          ),
          const SizedBox(height: 24),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: AppConstants.filterAll,
                  index: 0,
                  viewModel: viewModel,
                ),
                _FilterChip(
                  label: AppConstants.filterSent,
                  index: 1,
                  viewModel: viewModel,
                ),
                _FilterChip(
                  label: AppConstants.filterReview,
                  index: 2,
                  viewModel: viewModel,
                ),
                _FilterChip(
                  label: AppConstants.filterAccepted,
                  index: 3,
                  viewModel: viewModel,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final int index;
  final ApplicationsViewModel viewModel;

  const _FilterChip({
    required this.label,
    required this.index,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = viewModel.selectedFilterIndex == index;
    return GestureDetector(
      onTap: () => viewModel.setFilterIndex(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.only(left: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white
              : Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: isSelected ? AppColors.primary : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
