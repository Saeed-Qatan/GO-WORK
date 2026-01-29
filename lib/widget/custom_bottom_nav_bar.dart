import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../core/constants/app_constants.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      showUnselectedLabels: true,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      elevation: 0,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_filled),
          label: AppConstants.navHome,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: AppConstants.navSearch,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.description_outlined),
          label: AppConstants.navApplications,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today_outlined),
          label: AppConstants.navInterviews,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: AppConstants.navProfile,
        ),
      ],
    );
  }
}
