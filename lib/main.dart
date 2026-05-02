import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'theme/app_theme.dart';
import 'routing/app_router.dart';
import 'utils/snackbar_service.dart';
import 'services/push_notification_service.dart';

import 'viewmodel/auth/login_view_model.dart';
import 'viewmodel/home_view_model.dart';
import 'viewmodel/applications_view_model.dart';
import 'viewmodel/interviews_view_model.dart';
import 'viewmodel/profile_view_model.dart';
import 'viewmodel/job_details_view_model.dart';
import 'viewmodel/settings_view_model.dart';
import 'viewmodel/notifications_view_model.dart';

/// Singleton service instance — shared across the app lifetime.
final PushNotificationService pushNotificationService = PushNotificationService();

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Register the background message handler before Firebase.initializeApp
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await Firebase.initializeApp();
  await pushNotificationService.initialize();

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
        ChangeNotifierProvider(create: (_) => JobDetailsViewModel()),
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
        ChangeNotifierProvider(
          create: (_) => NotificationsViewModel(
            pushService: pushNotificationService,
          ),
        ),
      ],
      child: MaterialApp.router(
        title: 'Go Work',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        scaffoldMessengerKey: SnackbarService.messengerKey,
        
        // GoRouter Configuration
        routerConfig: appRouter,
        
        // Localization
        locale: const Locale('ar', 'AE'), // Default to Arabic
        supportedLocales: const [Locale('en', 'US'), Locale('ar', 'AE')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    );
  }
}
