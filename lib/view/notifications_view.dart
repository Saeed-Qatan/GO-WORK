import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../theme/app_colors.dart';
import '../viewmodel/notifications_view_model.dart';
import '../widget/common/animated_empty_state.dart';
import '../widget/common/animated_error_state.dart';
import '../widget/notifications/notification_card.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationsViewModel>().fetchNotifications(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 240) {
      context.read<NotificationsViewModel>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
        return _buildErrorState(viewModel);
      case NotificationsViewState.empty:
        return _buildEmptyState();
      case NotificationsViewState.loaded:
        return _buildNotificationsList(context, viewModel);
    }
  }

  Widget _buildNotificationsList(
    BuildContext context,
    NotificationsViewModel viewModel,
  ) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => viewModel.fetchNotifications(refresh: true),
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount:
            viewModel.notifications.length + (viewModel.isLoadingMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 2),
        itemBuilder: (context, index) {
          if (index >= viewModel.notifications.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final notification = viewModel.notifications[index];
          return Dismissible(
            key: ValueKey(notification.id),
            direction: DismissDirection.endToStart,
            background: _buildDismissBackground(),
            onDismissed: (_) => viewModel.hideNotification(notification.id),
            child: NotificationCard(
              notification: notification,
              onTap: () => viewModel.openNotification(context, notification),
              onDelete: () => viewModel.hideNotification(notification.id),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.delete_outline, color: Colors.white),
    );
  }

  Widget _buildEmptyState() {
    return const AnimatedEmptyState(
      icon: Icons.notifications_off_rounded,
      title: 'لا توجد إشعارات',
      subtitle: 'ستظهر هنا إشعاراتك عند وصولها.\nأنت الآن مطلع على كل شيء!',
    );
  }

  Widget _buildErrorState(NotificationsViewModel viewModel) {
    return AnimatedErrorState(
      title: 'حدث خطأ',
      message:
          viewModel.errorMessage ??
          'لم نتمكن من جلب الإشعارات. يرجى المحاولة لاحقاً.',
      onRetry: () => viewModel.fetchNotifications(refresh: true),
    );
  }
}
