import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/localization/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'repository/interviews_repository.dart';
import 'repository/profile_repository.dart';
import 'routing/app_router.dart';
import 'services/notification_topic_service.dart';
import 'services/push_notification_service.dart';
import 'utils/local_storage.dart';
import 'utils/snackbar_service.dart';
import 'viewmodel/applications_view_model.dart';
import 'viewmodel/auth/login_view_model.dart';
import 'viewmodel/home_view_model.dart';
import 'viewmodel/interviews_view_model.dart';
import 'viewmodel/job_application_state_view_model.dart';
import 'viewmodel/job_details_view_model.dart';
import 'viewmodel/notifications_view_model.dart';
import 'viewmodel/profile_view_model.dart';
import 'viewmodel/settings_view_model.dart';
import 'viewmodels/app/app_viewmodel.dart';

final PushNotificationService pushNotificationService =
    PushNotificationService();
final NotificationTopicService notificationTopicService =
    NotificationTopicService();

class GoWorkApp extends StatelessWidget {
  final AppViewModel appViewModel;

  const GoWorkApp({super.key, required this.appViewModel});

  @override
  Widget build(BuildContext context) {
    return EasyLocalization(
      supportedLocales: AppLocalizations.supportedLocales,
      path: AppLocalizations.translationsPath,
      fallbackLocale: AppLocalizations.fallbackLocale,
      startLocale: AppLocalizations.startLocale,
      child: MultiProvider(
        providers: [
          // Use .value so the provider holds the already-loaded instance
          // instead of creating a new one that triggers a notifyListeners race.
          ChangeNotifierProvider<AppViewModel>.value(value: appViewModel),
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
        child: const _MaterialAppHost(),
      ),
    );
  }
}

class _MaterialAppHost extends StatefulWidget {
  const _MaterialAppHost();

  @override
  State<_MaterialAppHost> createState() => _MaterialAppHostState();
}

class _MaterialAppHostState extends State<_MaterialAppHost> {
  late AppViewModel _appViewModel;
  bool _listenerAttached = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_initializeNotifications());
      // Sync locale once after the first frame — avoids build() loop.
      _syncLocaleIfNeeded();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_listenerAttached) {
      _appViewModel = context.read<AppViewModel>();
      _appViewModel.addListener(_onAppViewModelChanged);
      _listenerAttached = true;
    }
  }

  @override
  void dispose() {
    _appViewModel.removeListener(_onAppViewModelChanged);
    super.dispose();
  }

  /// Called whenever AppViewModel notifies (language / theme change).
  /// Syncs EasyLocalization locale outside of build() to prevent loops.
  void _onAppViewModelChanged() {
    if (!mounted) return;
    final currentLocale = EasyLocalization.of(context)?.locale;
    if (currentLocale != _appViewModel.locale) {
      unawaited(context.setLocale(_appViewModel.locale));
    }
  }

  /// One-time locale sync after settings are loaded.
  void _syncLocaleIfNeeded() {
    if (!mounted) return;
    final currentLocale = EasyLocalization.of(context)?.locale;
    if (currentLocale != _appViewModel.locale) {
      unawaited(context.setLocale(_appViewModel.locale));
    }
  }

  @override
  Widget build(BuildContext context) {
    final appViewModel = context.watch<AppViewModel>();
    AppColors.useDarkTheme(appViewModel.isDarkMode);
    return _buildRouterApp(appViewModel);
  }

  Widget _buildRouterApp(AppViewModel appViewModel) {
    return MaterialApp.router(
      key: const ValueKey('router_app'),
      title: 'Masarak',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: appViewModel.themeMode,
      scaffoldMessengerKey: SnackbarService.messengerKey,
      routerConfig: appRouter,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
      ),
      locale: appViewModel.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
    );
  }
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
  try {
    final token = await LocalStorage().getString('token');
    if (token == null || token.isEmpty) {
      final cachedCategoryId = await LocalStorage().getString('categoryId');
      await notificationTopicService.subscribeUserTopics(
        categoryId: cachedCategoryId,
      );
      return;
    }

    final profile = await ProfileRepository().getUserProfile();
    debugPrint(
      '=== STARTUP DEBUG: CATEGORY ID = ${profile.categoryId.isNotEmpty ? profile.categoryId : 'EMPTY'} ===',
    );
    await notificationTopicService.subscribeUserTopics(
      categoryId: profile.categoryId,
    );
  } catch (e) {
    debugPrint('=== FCM TOPICS: STARTUP USER TOPICS ERROR: $e ===');
    try {
      await notificationTopicService.subscribeUserTopics(categoryId: null);
    } catch (_) {}
  }
}
