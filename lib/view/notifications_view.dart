import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../viewmodel/notifications_view_model.dart';
import '../theme/app_colors.dart';
import '../widget/notifications/notification_card.dart';
import '../widget/common/animated_empty_state.dart';
import '../widget/common/animated_error_state.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationsViewModel>().fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: _buildAppBar(context),
      body: Consumer<NotificationsViewModel>(
        builder: (context, viewModel, child) {
          return _buildBody(context, viewModel);
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => context.pop(),
      ),
      title: const Text(
        'الإشعارات',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      actions: [
        Consumer<NotificationsViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.unreadCount == 0) return const SizedBox.shrink();
            return TextButton(
              onPressed: () => viewModel.markAllAsRead(),
              child: const Text(
                'قراءة الكل',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, NotificationsViewModel viewModel) {
    switch (viewModel.viewState) {
      case NotificationsViewState.loading:
      case NotificationsViewState.initial:
        return const Center(child: CircularProgressIndicator());

      case NotificationsViewState.error:
        return _buildErrorState(context, viewModel);

      case NotificationsViewState.empty:
        return _buildEmptyState(context);

      case NotificationsViewState.loaded:
        return _buildNotificationsList(viewModel);
    }
  }

  Widget _buildNotificationsList(NotificationsViewModel viewModel) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => viewModel.fetchNotifications(),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: viewModel.notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 2),
        itemBuilder: (context, index) {
          final notification = viewModel.notifications[index];
          return NotificationCard(
            notification: notification,
            onTap: () => viewModel.markAsRead(notification.id),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return const AnimatedEmptyState(
      icon: Icons.notifications_off_rounded,
      title: 'لا توجد إشعارات',
      subtitle: 'ستظهر هنا إشعاراتك عند وصولها.\nأنت الآن مطلع على كل شيء!',
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    NotificationsViewModel viewModel,
  ) {
    return AnimatedErrorState(
      title: 'حدث خطأ',
      message:
          viewModel.errorMessage ??
          'لم نتمكن من جلب الإشعارات. يرجى المحاولة لاحقاً.',
      onRetry: () => viewModel.fetchNotifications(),
    );
  }
}
