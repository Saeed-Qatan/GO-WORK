import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:provider/provider.dart';
import 'home_view.dart';
import 'search_view.dart';
import 'applications_view.dart';
import 'interviews_view.dart';
import 'settings_view.dart';
import '../widget/custom_bottom_nav_bar.dart';
import '../viewmodel/home_view_model.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeView(key: ValueKey('home')), // Home
    SearchView(key: ValueKey('search')), // Search
    ApplicationsView(key: ValueKey('applications')), // Applications
    InterviewsView(key: ValueKey('interviews')), // Interviews
    SettingsView(key: ValueKey('settings')), // Settings
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageTransitionSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
          return FadeThroughTransition(
            animation: primaryAnimation,
            secondaryAnimation: secondaryAnimation,
            child: child,
          );
        },
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          context.read<HomeViewModel>().clearSearch();
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
