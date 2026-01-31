import 'package:flutter/material.dart';
import 'home_view.dart';
import 'search_view.dart';
import 'applications_view.dart';
import 'interviews_view.dart';
import 'profile_view.dart';
import '../theme/app_colors.dart';
import '../core/constants/app_constants.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeView(), // Home
    SearchView(), // Search
    ApplicationsView(), // Applications
    InterviewsView(), // Interviews
    ProfileView(), // Profile
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: AppConstants.navHome,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search), // Search Icon
            activeIcon: Icon(
              Icons.search,
              weight: 700,
            ), // Bold/Active variant if available
            label: 'البحث', // 'Search' in Arabic
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: AppConstants.navApplications,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: AppConstants.navInterviews,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: AppConstants.navProfile,
          ),
        ],
      ),
    );
  }
}
