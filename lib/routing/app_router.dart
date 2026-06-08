import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animations/animations.dart';

// Views
import 'package:gowork/model/auth/register_data_model.dart';
import 'package:gowork/view/splash_view.dart';
import 'package:gowork/view/auth/login_view.dart';
import 'package:gowork/view/auth/register_info_page.dart';
import 'package:gowork/view/auth/register_photo_page.dart';
import 'package:gowork/view/auth/register_cv_skills_page.dart';
import 'package:gowork/view/auth/email_verification_page.dart';
import 'package:gowork/view/auth/forget_page.dart';
import 'package:gowork/view/auth/reset_password_view.dart';
import 'package:gowork/view/auth/change_password_view.dart';
import 'package:gowork/view/job_details_view.dart';
import 'package:gowork/view/main_view.dart';
import 'package:gowork/view/onboarding_view.dart';
import 'package:gowork/view/edit_profile_view.dart';
import 'package:gowork/view/profile_view.dart';
import 'package:gowork/view/settings_view.dart';
import 'package:gowork/view/feedback_view.dart';
import 'package:gowork/view/notifications_view.dart';
import 'package:gowork/model/home/home_model.dart';
import 'package:gowork/view/error/no_internet_view.dart';
import 'package:gowork/view/error/session_expired_view.dart';
import 'package:gowork/model/interview_model.dart';
import 'package:gowork/view/interview_details_view.dart';
import 'package:gowork/view/deleted_interviews_view.dart';

/// Centralized route names
class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String registerInfo = '/registerInfo';
  static const String registerPhoto = '/registerPhoto';
  static const String registerCV = '/registerCV';
  static const String verifyEmail = '/verifyEmail';
  static const String forgetPassword = '/forgetPassword';
  static const String resetPassword = '/resetPassword';
  static const String changePassword = '/changePassword';
  static const String home = '/home';
  static const String editProfile = '/editProfile';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String feedback = '/feedback';
  static const String jobDetails = '/jobDetails';
  static const String notifications = '/notifications';
  static const String noInternet = '/error/noInternet';
  static const String sessionExpired = '/error/sessionExpired';
  static const String interviewDetails = '/interviewDetails';
  static const String deletedInterviews = '/deletedInterviews';
}

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// GoRouter configuration
final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashView(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) {
        final nextRoute = state.uri.queryParameters['next'];
        final safeNextRoute = nextRoute == AppRoutes.home
            ? AppRoutes.home
            : AppRoutes.login;

        return OnboardingView(nextRoute: safeNextRoute);
      },
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginView(),
    ),
    GoRoute(
      path: AppRoutes.registerInfo,
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: AppRoutes.registerPhoto,
      builder: (context, state) {
        final data = state.extra as RegisterDataModel;
        return RegisterPhotoPage(data: data);
      },
    ),
    GoRoute(
      path: AppRoutes.registerCV,
      builder: (context, state) {
        final data = state.extra as RegisterDataModel;
        return RegisterCVPage(data: data);
      },
    ),
    GoRoute(
      path: AppRoutes.verifyEmail,
      builder: (context, state) {
        return EmailVerificationPage(args: state.extra);
      },
    ),
    GoRoute(
      path: AppRoutes.forgetPassword,
      builder: (context, state) => const ForgetPage(),
    ),
    GoRoute(
      path: AppRoutes.resetPassword,
      builder: (context, state) {
        final email = state.extra as String;
        return ResetPasswordView(email: email);
      },
    ),
    GoRoute(
      path: AppRoutes.changePassword,
      builder: (context, state) => const ChangePasswordView(),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const MainView(),
    ),
    GoRoute(
      path: AppRoutes.editProfile,
      builder: (context, state) => const EditProfileView(),
    ),
    GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) => const ProfileView(),
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsView(),
    ),
    GoRoute(
      path: AppRoutes.feedback,
      builder: (context, state) => const FeedbackView(),
    ),
    GoRoute(
      path: AppRoutes.notifications,
      builder: (context, state) => const NotificationsView(),
    ),
    GoRoute(
      path: AppRoutes.jobDetails,
      pageBuilder: (context, state) {
        final job = state.extra as JobModel;
        return CustomTransitionPage(
          key: state.pageKey,
          child: JobDetailsView(job: job),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SharedAxisTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              transitionType: SharedAxisTransitionType.scaled,
              child: child,
            );
          },
        );
      },
    ),
    GoRoute(
      path: AppRoutes.noInternet,
      builder: (context, state) => const NoInternetView(),
    ),
    GoRoute(
      path: AppRoutes.sessionExpired,
      builder: (context, state) => const SessionExpiredView(),
    ),
    GoRoute(
      path: AppRoutes.interviewDetails,
      pageBuilder: (context, state) {
        final interview = state.extra as InterviewModel;
        return CustomTransitionPage(
          key: state.pageKey,
          child: InterviewDetailsView(interview: interview),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SharedAxisTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              transitionType: SharedAxisTransitionType.scaled,
              child: child,
            );
          },
        );
      },
    ),
    GoRoute(
      path: AppRoutes.deletedInterviews,
      builder: (context, state) => const DeletedInterviewsView(),
    ),
  ],
);
