import 'package:flutter/material.dart';

import 'package:gowork/view/splash_view.dart';

import 'package:provider/provider.dart';
import 'theme/app_theme.dart';

import 'package:gowork/utils/navigations.dart';
import 'package:gowork/utils/snackbar_service.dart';
import 'package:gowork/view/auth/login_view.dart';
import 'package:gowork/view/auth/register_info_page.dart';
import 'package:gowork/view/auth/register_photo_page.dart';
import 'package:gowork/view/auth/register_cv_skills_page.dart';
import 'package:gowork/view/auth/email_verification_page.dart';
import 'package:gowork/view/edit_profile_view.dart';

import 'viewmodel/auth/login_view_model.dart';
import 'viewmodel/home_view_model.dart';
import 'viewmodel/applications_view_model.dart';
import 'viewmodel/interviews_view_model.dart';
import 'viewmodel/profile_view_model.dart';
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
        scaffoldMessengerKey: SnackbarService.messengerKey,
        locale: const Locale('ar', 'AE'), // Default to Arabic as per screenshot
        supportedLocales: const [Locale('en', 'US'), Locale('ar', 'AE')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routes: {
          Routes.login: (context) => const LoginView(),
          Routes.registerInfo: (context) => const RegisterPage(),
          Routes.registerPhoto: (context) => const RegisterPhotoPage(),
          Routes.registerCV: (context) => const RegisterCVPage(),
          Routes.verifyEmail: (context) => const EmailVerificationPage(),
          Routes.editProfile: (context) => const EditProfileView(),
        },
        home: const SplashView(),
      ),
    );
  }
}
