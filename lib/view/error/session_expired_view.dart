import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gowork/routing/app_router.dart';
import 'package:gowork/theme/app_colors.dart';
import 'package:gowork/utils/session_state_reset.dart';
import 'error_page_view.dart';

/// A view shown when the user's session has expired (401 Unauthorized).
class SessionExpiredView extends StatelessWidget {
  const SessionExpiredView({super.key});

  @override
  Widget build(BuildContext context) {
    return ErrorPageView(
      data: ErrorPageData(
        title: 'انتهت صلاحية الجلسة',
        message: 'لقد انتهت صلاحية الجلسة الخاصة بك لدواعي الأمان. يرجى تسجيل الدخول مجدداً لمتابعة استخدام التطبيق.',
        icon: Icons.history_toggle_off_rounded,
        themeColor: AppColors.primary,
        actionLabel: 'تسجيل الدخول',
        onAction: () {
          resetSessionState(context);
          context.go(AppRoutes.login);
        },
      ),
    );
  }
}
