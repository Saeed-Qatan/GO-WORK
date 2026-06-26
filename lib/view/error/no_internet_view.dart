import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gowork/routing/app_router.dart';
import 'package:gowork/theme/app_colors.dart';
import 'package:gowork/utils/snackbar_service.dart';
import 'error_page_view.dart';

/// A view shown when there is no internet connection.
class NoInternetView extends StatelessWidget {
  const NoInternetView({super.key});

  Future<void> _handleRetry(BuildContext context) async {
    final hasInternet = await _checkConnection();
    if (!context.mounted) return;

    if (hasInternet) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(AppRoutes.login);
      }
    } else {
      SnackbarService.showWarning('لا يزال الاتصال بالإنترنت مقطوعاً، يرجى المحاولة مرة أخرى');
    }
  }

  Future<bool> _checkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 4));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ErrorPageView(
      data: ErrorPageData(
        title: 'لا يوجد اتصال بالإنترنت',
        message: 'يبدو أنك غير متصل بالإنترنت حالياً. يرجى التحقق من اتصال الشبكة وإعادة المحاولة.',
        icon: Icons.wifi_off_rounded,
        themeColor: AppColors.primary,
        actionLabel: 'إعادة المحاولة',
        onAction: () => _handleRetry(context),
      ),
    );
  }
}
