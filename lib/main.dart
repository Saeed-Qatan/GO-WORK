import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'theme/app_theme.dart';
import 'routing/app_router.dart';
import 'utils/snackbar_service.dart';
import 'utils/local_storage.dart';
import 'services/notification_topic_service.dart';
import 'services/notification_navigation_service.dart';
import 'services/push_notification_service.dart';
import 'repository/profile_repository.dart';

import 'viewmodel/auth/login_view_model.dart';
import 'viewmodel/home_view_model.dart';
import 'viewmodel/applications_view_model.dart';
import 'viewmodel/interviews_view_model.dart';
import 'viewmodel/profile_view_model.dart';
import 'viewmodel/job_details_view_model.dart';
import 'viewmodel/job_application_state_view_model.dart';
import 'viewmodel/settings_view_model.dart';
import 'viewmodel/notifications_view_model.dart';
import 'repository/interviews_repository.dart';

/// Singleton service instance — shared across the app lifetime.
final PushNotificationService pushNotificationService =
    PushNotificationService();
final NotificationTopicService notificationTopicService =
    NotificationTopicService();

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Register the background message handler before Firebase.initializeApp
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await Firebase.initializeApp();
  await _initializeNotifications();

  runApp(const MyApp());
}

Future<void> _initializeNotifications() async {
  try {
    await pushNotificationService.initialize();
  } catch (e) {
    debugPrint('=== FCM: PUSH NOTIFICATION INITIALIZE ERROR: $e ===');
  }

  await _subscribeToCurrentUserTopics();
}

Future<void> _subscribeToCurrentUserTopics() async {
  final token = await LocalStorage().getString('token');
  if (token == null || token.isEmpty) {
    await notificationTopicService.subscribeUserTopics(categoryId: null);
    return;
  }

  try {
    final profile = await ProfileRepository().getUserProfile();
    debugPrint(
      '=== STARTUP DEBUG: CATEGORY ID = ${profile.categoryId.isNotEmpty ? profile.categoryId : 'EMPTY'} ===',
    );
    await notificationTopicService.subscribeUserTopics(
      categoryId: profile.categoryId,
    );
  } catch (e) {
    debugPrint('=== FCM TOPICS: STARTUP USER TOPICS ERROR: $e ===');
    await notificationTopicService.subscribeUserTopics(categoryId: null);
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final NotificationNavigationService _notificationNavigationService =
      NotificationNavigationService();
  StreamSubscription<NotificationTapAction>? _notificationTapSubscription;

  @override
  void initState() {
    super.initState();
    _notificationTapSubscription = pushNotificationService.onNotificationTapped
        .listen(_openNotificationsFromSystemTap);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(pushNotificationService.ensureDeviceNotificationSetup());
      if (!pushNotificationService.hasPendingNotificationTap) return;
      final pendingAction = pushNotificationService
          .takePendingTappedNotificationAction();
      if (pendingAction != null) {
        _openNotificationsFromSystemTap(pendingAction);
      }
    });
  }

  Future<void> _openNotificationsFromSystemTap(
    NotificationTapAction action,
  ) async {
    await _syncCachedNotifications();
    await _markTappedNotificationRead(action.notificationId);

    try {
      if (await _notificationNavigationService.openActionUrl(
        action.actionUrl,
      )) {
        return;
      }
    } catch (e) {
      debugPrint('=== NOTIFICATION TAP ACTION ERROR: $e ===');
    }

    _notificationNavigationService.openFallbackNotifications();
  }

  Future<void> _syncCachedNotifications() async {
    final navigatorContext = rootNavigatorKey.currentContext;
    if (navigatorContext == null) return;

    try {
      await navigatorContext
          .read<NotificationsViewModel>()
          .syncCachedNotifications();
    } catch (e) {
      debugPrint('=== NOTIFICATION TAP CACHE SYNC ERROR: $e ===');
    }
  }

  Future<void> _markTappedNotificationRead(int? notificationId) async {
    if (notificationId == null) return;

    final navigatorContext = rootNavigatorKey.currentContext;
    if (navigatorContext == null) return;

    try {
      await navigatorContext.read<NotificationsViewModel>().markAsRead(
        notificationId,
      );
    } catch (e) {
      debugPrint('=== NOTIFICATION TAP MARK READ ERROR: $e ===');
    }
  }

  @override
  void dispose() {
    _notificationTapSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => LoginViewModel(
            pushNotificationService: pushNotificationService,
            notificationTopicService: notificationTopicService,
          ),
        ),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => JobApplicationStateViewModel()),
        ChangeNotifierProvider(create: (_) => ApplicationsViewModel()),
        ChangeNotifierProvider(
          create: (_) =>
              InterviewsViewModel(repository: InterviewsRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileViewModel(
            notificationTopicService: notificationTopicService,
          ),
        ),
        ChangeNotifierProvider(create: (_) => JobDetailsViewModel()),
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
        ChangeNotifierProvider(
          create: (_) =>
              NotificationsViewModel(pushService: pushNotificationService),
        ),
      ],
      child: MaterialApp.router(
        title: 'Masarak',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        scaffoldMessengerKey: SnackbarService.messengerKey,

        // GoRouter Configuration
        routerConfig: appRouter,

        // Global Premium Scroll Physics
        scrollBehavior: const MaterialScrollBehavior().copyWith(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
        ),

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
