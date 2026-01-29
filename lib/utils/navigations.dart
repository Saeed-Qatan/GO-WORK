import 'package:flutter/material.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Future<dynamic> navigateTo(Widget page) {
    return navigatorKey.currentState!.push(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  static Future<dynamic> pushReplacement(Widget page) {
    return navigatorKey.currentState!.pushReplacement(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  static Future<dynamic> pushAndRemoveUntil(Widget page) {
    return navigatorKey.currentState!.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => page),
      (route) => false,
    );
  }

  static void goBack() {
    return navigatorKey.currentState!.pop();
  }
}
