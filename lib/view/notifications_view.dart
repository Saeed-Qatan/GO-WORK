import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../model/notification_model.dart';
import '../theme/app_colors.dart';
import '../viewmodel/notifications_view_model.dart';
import '../widget/common/animated_empty_state.dart';
import '../widget/common/animated_error_state.dart';
import '../widget/notifications/notification_card.dart';

enum _NotificationFilter { all, unread, read }

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  final ScrollController _scrollController = ScrollController();
  _NotificationFilter _selectedFilter = _NotificationFilter.all;

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
    final hasNotifications = viewModel.notifications.isNotEmpty;

    if ((viewModel.viewState == NotificationsViewState.loading ||
            viewModel.viewState == NotificationsViewState.initial) &&
        !hasNotifications) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.viewState == NotificationsViewState.error &&
        !hasNotifications) {
      return _buildErrorState(viewModel);
    }

    final filtered = _filteredNotifications(viewModel);

    return Column(
      children: [
        _buildFilterTabs(viewModel),
        Expanded(
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => viewModel.fetchNotifications(refresh: true),
            child: filtered.isEmpty
                ? _buildFilteredEmptyState()
                : _buildNotificationsList(context, viewModel, filtered),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTabs(NotificationsViewModel viewModel) {
    final tabs = [
      _FilterTabData(
        filter: _NotificationFilter.all,
        label: 'الكل',
        count: viewModel.notifications.length,
      ),
      _FilterTabData(
        filter: _NotificationFilter.unread,
        label: 'غير مقروءة',
        count: viewModel.unreadNotifications.length,
      ),
      _FilterTabData(
        filter: _NotificationFilter.read,
        label: 'مقروءة',
        count: viewModel.readNotifications.length,
      ),
    ];

    return Container(
      width: double.infinity,
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Row(
        children: tabs
            .map(
              (tab) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: _buildFilterButton(tab),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildFilterButton(_FilterTabData tab) {
    final selected = _selectedFilter == tab.filter;

    return SizedBox(
      height: 42,
      child: TextButton(
        onPressed: () => setState(() => _selectedFilter = tab.filter),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          foregroundColor: selected ? Colors.white : AppColors.textSecondary,
          backgroundColor: selected
              ? AppColors.primary
              : AppColors.inputBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                tab.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withValues(alpha: 0.20)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  tab.count > 99 ? '99+' : '${tab.count}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected ? Colors.white : AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationsList(
    BuildContext context,
    NotificationsViewModel viewModel,
    List<NotificationModel> notifications,
  ) {
    return ListView.separated(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: notifications.length + (viewModel.isLoadingMore ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 2),
      itemBuilder: (context, index) {
        if (index >= notifications.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final notification = notifications[index];
        return Dismissible(
          key: ValueKey(notification.id),
          direction: DismissDirection.endToStart,
          background: _buildDismissBackground(),
          confirmDismiss: (_) async {
            await viewModel.hideNotification(notification.id);
            return false;
          },
          child: NotificationCard(
            notification: notification,
            onTap: () => viewModel.openNotification(context, notification),
            onDelete: () {
              viewModel.hideNotification(notification.id);
            },
          ),
        );
      },
    );
  }

  List<NotificationModel> _filteredNotifications(
    NotificationsViewModel viewModel,
  ) {
    switch (_selectedFilter) {
      case _NotificationFilter.all:
        return viewModel.notifications;
      case _NotificationFilter.unread:
        return viewModel.unreadNotifications;
      case _NotificationFilter.read:
        return viewModel.readNotifications;
    }
  }

  Widget _buildDismissBackground() {
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.delete_outline, color: Colors.white),
    );
  }

  Widget _buildFilteredEmptyState() {
    switch (_selectedFilter) {
      case _NotificationFilter.all:
        return _emptyList(
          title: 'لا توجد إشعارات',
          subtitle: 'ستظهر هنا إشعاراتك عند وصولها.',
        );
      case _NotificationFilter.unread:
        return _emptyList(
          title: 'لا توجد إشعارات غير مقروءة',
          subtitle: 'أنت مطلع على كل الإشعارات الحالية.',
        );
      case _NotificationFilter.read:
        return _emptyList(
          title: 'لا توجد إشعارات مقروءة',
          subtitle: 'الإشعارات التي تفتحها ستظهر هنا.',
        );
    }
  }

  Widget _emptyList({required String title, required String subtitle}) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      children: [
        const SizedBox(height: 96),
        AnimatedEmptyState(
          icon: Icons.notifications_off_rounded,
          title: title,
          subtitle: subtitle,
        ),
      ],
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

class _FilterTabData {
  final _NotificationFilter filter;
  final String label;
  final int count;

  const _FilterTabData({
    required this.filter,
    required this.label,
    required this.count,
  });
}
