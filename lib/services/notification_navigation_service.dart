import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../routing/app_router.dart';
import 'job_service.dart';

class NotificationNavigationService {
  final JobService _jobService;

  NotificationNavigationService({JobService? jobService})
    : _jobService = jobService ?? JobService();

  Future<bool> openActionUrl(
    String? actionUrl, {
    BuildContext? context,
    bool replace = true,
  }) async {
    final target = actionUrl?.trim();
    if (target == null || target.isEmpty) return false;

    final internalPath = _internalPath(target);
    if (internalPath == null) return false;

    final uri = Uri.tryParse(internalPath);
    if (uri == null) return false;

    final segments = uri.pathSegments;
    if (segments.length == 2 && segments.first.toLowerCase() == 'jobs') {
      return _openJob(segments[1], context: context, replace: replace);
    }

    if (_knownInternalRoutes.contains(uri.path)) {
      _navigate(uri.path, context: context, replace: replace);
      return true;
    }

    return false;
  }

  Future<bool> openFromSystemTap(String? actionUrl) async {
    final target = actionUrl?.trim();
    if (target == null || target.isEmpty) return false;

    final internalPath = _internalPath(target);
    if (internalPath == null) return false;

    final uri = Uri.tryParse(internalPath);
    if (uri == null) return false;

    final segments = uri.pathSegments;
    if (segments.length == 2 && segments.first.toLowerCase() == 'jobs') {
      try {
        await _ensureSystemTapBaseRoute();
        final job = await _jobService.getJobById(segments[1]);
        if (job == null) return false;
        _push(AppRoutes.jobDetails, extra: job);
        return true;
      } catch (e) {
        debugPrint('=== NOTIFICATION TAP JOB ACTION ERROR: $e ===');
        return false;
      }
    }

    if (_knownInternalRoutes.contains(uri.path)) {
      if (uri.path == AppRoutes.home) {
        appRouter.go(AppRoutes.home);
        return true;
      }

      await _ensureSystemTapBaseRoute();
      _push(uri.path);
      return true;
    }

    return false;
  }

  void openFallbackNotifications({BuildContext? context, bool replace = true}) {
    _navigate(AppRoutes.notifications, context: context, replace: replace);
  }

  Future<void> openFallbackNotificationsFromSystemTap() async {
    await _ensureSystemTapBaseRoute();
    _push(AppRoutes.notifications);
  }

  Future<bool> _openJob(
    String jobId, {
    required BuildContext? context,
    required bool replace,
  }) async {
    final job = await _jobService.getJobById(jobId);
    if (job == null) return false;
    if (context != null && !context.mounted) return false;

    if (context != null) {
      if (replace) {
        context.go(AppRoutes.jobDetails, extra: job);
      } else {
        context.push(AppRoutes.jobDetails, extra: job);
      }
    } else {
      appRouter.go(AppRoutes.jobDetails, extra: job);
    }
    return true;
  }

  void _navigate(
    String path, {
    required BuildContext? context,
    required bool replace,
  }) {
    if (context != null) {
      if (replace) {
        context.go(path);
      } else {
        context.push(path);
      }
      return;
    }

    appRouter.go(path);
  }

  Future<void> _ensureSystemTapBaseRoute() async {
    if (!_needsHomeBaseForSystemTap(_currentPath())) return;

    appRouter.go(AppRoutes.home);
    await Future<void>.delayed(Duration.zero);
  }

  void _push(String path, {Object? extra}) {
    final context = rootNavigatorKey.currentContext;
    if (context != null && context.mounted) {
      context.push(path, extra: extra);
      return;
    }

    appRouter.push(path, extra: extra);
  }

  String? _currentPath() {
    try {
      return appRouter.routeInformationProvider.value.uri.path;
    } catch (_) {
      return null;
    }
  }

  bool _needsHomeBaseForSystemTap(String? path) {
    return path == null || path.isEmpty || _startupRoutes.contains(path);
  }

  String? _internalPath(String target) {
    final uri = Uri.tryParse(target);
    final rawPath = uri?.path.isNotEmpty == true ? uri!.path : target;
    final path = rawPath.startsWith('/') ? rawPath : '/$rawPath';
    return Uri.tryParse(path)?.path;
  }
}

const Set<String> _knownInternalRoutes = {
  AppRoutes.home,
  AppRoutes.profile,
  AppRoutes.settings,
  AppRoutes.feedback,
  AppRoutes.notifications,
  AppRoutes.changePassword,
  AppRoutes.deletedInterviews,
};

const Set<String> _startupRoutes = {
  AppRoutes.splash,
  AppRoutes.login,
  AppRoutes.onboarding,
};
