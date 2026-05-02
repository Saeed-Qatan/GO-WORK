import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../viewmodel/applications_view_model.dart';

class ApplicationsHeader extends StatelessWidget {
  final ApplicationsViewModel viewModel;

  const ApplicationsHeader({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 40, bottom: 20),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
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
          ),
          const SizedBox(height: 24),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: List.generate(
                viewModel.filterTabs.length,
                (index) => _FilterChip(
                  label: viewModel.filterTabs[index],
                  index: index,
                  viewModel: viewModel,
                ),
              ),
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: isSelected ? AppColors.primary : Colors.white.withValues(alpha: 0.7),
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                letterSpacing: 0.3,
              ),
        ),
      ),
    );
  }
}
