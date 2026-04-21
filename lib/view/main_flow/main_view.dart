import 'package:flutter/material.dart';
import 'package:gowork/view/applications_view.dart';
import 'package:gowork/view/interviews_view.dart';
import 'package:gowork/widget/custom_bottom_nav_bar.dart';
import 'home_view.dart';

import 'profile_view.dart';
import 'search_view.dart';


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
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
