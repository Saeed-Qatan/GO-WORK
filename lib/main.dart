import 'package:flutter/material.dart';

import 'package:gowork/view/splash_view.dart';

import 'package:provider/provider.dart';
import 'theme/app_theme.dart';

import 'package:gowork/utils/navigations.dart';
import 'viewmodel/auth/login_view_model.dart';
import 'viewmodel/home/home_view_model.dart';
import 'viewmodel/applications/applications_view_model.dart';
import 'viewmodel/interviews/interviews_view_model.dart';
import 'viewmodel/profile/profile_view_model.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => ApplicationsViewModel()),
        ChangeNotifierProvider(create: (_) => InterviewsViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
      ],
      child: MaterialApp(
        title: 'Go Work',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        navigatorKey: NavigationService.navigatorKey,
        locale: const Locale('ar', 'AE'), // Default to Arabic as per screenshot
        supportedLocales: const [Locale('en', 'US'), Locale('ar', 'AE')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const SplashView(),
      ),
    );
  }
}
