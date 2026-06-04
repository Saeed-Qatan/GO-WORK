import 'package:flutter/material.dart';

import '../../model/notification_model.dart';
import '../../theme/app_colors.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notification.isRead
              ? AppColors.surface
              : AppColors.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notification.isRead
                ? AppColors.border
                : AppColors.primary.withValues(alpha: 0.32),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLeading(),
            const SizedBox(width: 12),
            Expanded(child: _buildContent(context)),
            const SizedBox(width: 6),
            Column(
              children: [
                _buildDeleteButton(),
                if (!notification.isRead) ...[
                  const SizedBox(height: 8),
                  _buildUnreadDot(),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeading() {
    final imageUrl = notification.imageUrl;
    if (imageUrl != null && Uri.tryParse(imageUrl)?.isAbsolute == true) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(
          imageUrl,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildIcon(),
        ),
      );
    }
    return _buildIcon();
  }

  Widget _buildIcon() {
    final color = _typeColor();
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: notification.isRead
            ? AppColors.inputBackground
            : color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _typeIcon(),
        color: notification.isRead ? AppColors.textHint : color,
        size: 22,
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          notification.title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.bold,
            color: AppColors.textPrimary,
            height: 1.4,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          notification.body,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Icon(Icons.schedule, size: 13, color: AppColors.textHint),
            const SizedBox(width: 4),
            Text(
              _formatDate(notification.createdAt),
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: AppColors.textHint),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDeleteButton() {
    return SizedBox(
      width: 32,
      height: 32,
      child: IconButton(
        tooltip: 'حذف',
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        onPressed: onDelete,
        icon: const Icon(
          Icons.close_rounded,
          size: 18,
          color: AppColors.textHint,
        ),
      ),
    );
  }

  Widget _buildUnreadDot() {
    return Container(
      width: 9,
      height: 9,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
    );
  }

  IconData _typeIcon() {
    switch (notification.type) {
      case NotificationType.jobCreated:
        return Icons.work_outline;
      case NotificationType.applicationAccepted:
        return Icons.check_circle_outline;
      case NotificationType.applicationRejected:
        return Icons.cancel_outlined;
      case NotificationType.interviewScheduled:
        return Icons.event_available_outlined;
      case NotificationType.general:
      case NotificationType.unknown:
        return Icons.notifications_outlined;
    }
  }

  Color _typeColor() {
    switch (notification.type) {
      case NotificationType.applicationAccepted:
        return AppColors.success;
      case NotificationType.applicationRejected:
        return AppColors.error;
      case NotificationType.interviewScheduled:
        return AppColors.warning;
      case NotificationType.jobCreated:
        return AppColors.primary;
      case NotificationType.general:
      case NotificationType.unknown:
        return AppColors.info;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date.toLocal());

    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';

    final localDate = date.toLocal();
    final month = localDate.month.toString().padLeft(2, '0');
    final day = localDate.day.toString().padLeft(2, '0');
    return '${localDate.year}/$month/$day';
  }
}
